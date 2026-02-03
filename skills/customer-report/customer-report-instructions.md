# Customer Report Skill Instructions

When the user invokes `/customer-report [account_name] [months]`, follow these steps:

## Step 1: Parse Parameters

- `account_name`: Required - the customer name to search for
- `months`: Optional - number of months (default: 12)

## Step 2: Search for Account

Run this query to find the ultimate parent company name:

```sql
SELECT DISTINCT ultimate_parent_company_name
FROM rds.rep_job_metrics
WHERE ultimate_parent_company_name ILIKE '%{account_name}%'
  AND date_dt >= CURRENT_DATE - INTERVAL '{months} months'
LIMIT 10
```

If multiple matches found, ask user to select the correct one.

## Step 3: Query Total Metrics

```sql
SELECT
    product_type,
    COUNT(DISTINCT job_id) as total_jobs,
    SUM(pageviews) as total_pageviews,
    SUM(active_application_start_count + passive_application_start_count) as applications_started,
    SUM(active_application_sent_count + passive_application_sent_count) as applications_sent,
    SUM(net_revenue_eur) as total_spend_eur,
    ROUND(
        CASE WHEN SUM(active_application_sent_count + passive_application_sent_count) > 0
        THEN SUM(net_revenue_eur) / SUM(active_application_sent_count + passive_application_sent_count)
        ELSE 0 END, 2
    ) as avg_cpa_eur
FROM rds.rep_job_metrics
WHERE ultimate_parent_company_name = '{account_name}'
  AND date_dt >= CURRENT_DATE - INTERVAL '{months} months'
  AND product_type IN ('Reach', 'Hire')
GROUP BY product_type
ORDER BY product_type
```

## Step 4: Query Monthly CPA Trending

```sql
SELECT
    product_type,
    DATE_TRUNC('month', date_dt) as month,
    COUNT(DISTINCT job_id) as jobs_posted,
    SUM(active_application_sent_count + passive_application_sent_count) as applications_sent,
    SUM(net_revenue_eur) as total_spend_eur,
    ROUND(
        CASE WHEN SUM(active_application_sent_count + passive_application_sent_count) > 0
        THEN SUM(net_revenue_eur) / SUM(active_application_sent_count + passive_application_sent_count)
        ELSE 0 END, 2
    ) as cpa_eur
FROM rds.rep_job_metrics
WHERE ultimate_parent_company_name = '{account_name}'
  AND date_dt >= CURRENT_DATE - INTERVAL '{months} months'
  AND product_type IN ('Reach', 'Hire')
GROUP BY product_type, DATE_TRUNC('month', date_dt)
ORDER BY product_type, month
```

## Step 5: Query Monthly Applications Trending

```sql
SELECT
    product_type,
    DATE_TRUNC('month', date_dt) as month,
    SUM(active_application_start_count + passive_application_start_count) as applications_started,
    SUM(active_application_sent_count + passive_application_sent_count) as applications_sent,
    ROUND(
        CASE WHEN SUM(active_application_start_count + passive_application_start_count) > 0
        THEN 100.0 * SUM(active_application_sent_count + passive_application_sent_count) /
             SUM(active_application_start_count + passive_application_start_count)
        ELSE 0 END, 2
    ) as conversion_pct
FROM rds.rep_job_metrics
WHERE ultimate_parent_company_name = '{account_name}'
  AND date_dt >= CURRENT_DATE - INTERVAL '{months} months'
  AND product_type IN ('Reach', 'Hire')
GROUP BY product_type, DATE_TRUNC('month', date_dt)
ORDER BY product_type, month
```

## Step 6: Query Budget Data

```sql
-- Current remaining budget by product type
SELECT
    product_type,
    SUM(remaining_total_credit_eur) as current_remaining_budget_eur
FROM (
    SELECT
        product_type,
        purchase_id,
        remaining_total_credit_eur,
        ROW_NUMBER() OVER (PARTITION BY purchase_id ORDER BY date DESC) as rn
    FROM rds.rep_accounting
    WHERE ultimate_parent_company_name = '{account_name}'
      AND product_type IN ('Reach', 'Hire')
)
WHERE rn = 1
GROUP BY product_type
ORDER BY product_type
```

## Step 7: Generate Report Data JSON

Create a JSON file with this structure:

```json
{
    "account_name": "Account Name",
    "time_range_months": 12,
    "date_from": "Feb 2025",
    "date_to": "Feb 2026",
    "total": {
        "booked_budget": 1369564,
        "used_budget": 1688903,
        "available_budget": 1035135,
        "total_jobs": 27583,
        "page_views": 2069947,
        "applications_started": 347386,
        "applications_sent": 109523,
        "avg_cpa": 12.08
    },
    "reach": {
        "booked_budget": 980085,
        "used_budget": 930465,
        "available_budget": 982200,
        "total_jobs": 27065,
        "page_views": 1758797,
        "applications_started": 292563,
        "applications_sent": 101245,
        "avg_cpa": 9.19,
        "conversion_rate": 34.6,
        "monthly_cpa": [["Feb", 9.25, 6830], ["Mar", 11.23, 6950], ...],
        "monthly_apps": [["Feb", 26502, 8213], ["Mar", 20753, 7286], ...]
    },
    "hire": {
        "booked_budget": 389479,
        "used_budget": 401138,
        "available_budget": 52935,
        "total_jobs": 518,
        "page_views": 311150,
        "applications_started": 54823,
        "applications_sent": 8278,
        "avg_cpa": 48.46,
        "conversion_rate": 15.1,
        "monthly_cpa": [["Feb", 65.14, 87], ["Mar", 51.44, 75], ...],
        "monthly_apps": [["Feb", 3809, 565], ["Mar", 3178, 676], ...]
    }
}
```

## Step 8: Generate PowerPoint

1. Save the JSON data to a temp file
2. Run the Python generator script:

```bash
python ~/.claude/skills/customer_report_generator.py /path/to/data.json ~/Desktop/Template.pptx ~/Desktop/{AccountName}_Customer_Report.pptx
```

## Step 9: Report to User

Tell the user where the report was saved and provide a summary of the key metrics.

## Month Labels

Use German 3-letter month abbreviations:
- Jan, Feb, Mär, Apr, Mai, Jun, Jul, Aug, Sep, Okt, Nov, Dez
