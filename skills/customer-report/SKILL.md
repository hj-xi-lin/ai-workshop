---
name: customer-report
description: Generate comprehensive customer performance reports with REACH/HIRE split analysis from Redshift data, outputting a professional PowerPoint presentation
argument-hint: [account_name] [timeframe]
disable-model-invocation: true
allowed-tools: mcp__plugin_redshift-metadata-discovery_redshift__execute_query, Bash, Write, Read
---

# Customer Performance Report Generator

Generate comprehensive customer performance reports with REACH/HIRE split analysis.

## Usage

```
/customer-report [account_name] [timeframe]
```

**Parameters:**
- `account_name` (required): The ultimate parent company name to analyze (e.g., "REWE", "Deutsche Bahn")
- `timeframe` (optional): Flexible time period specification (default: 12 months)

**Supported Timeframe Formats:**

| Format | Example | Description |
|--------|---------|-------------|
| Number | `12` | Last N months |
| Date range | `2024-06-01 2025-01-31` | Specific start and end dates |
| Month range | `Jun2024 Jan2025` | Month-year to month-year |
| YTD | `YTD` | Year to date (Jan 1 to today) |
| Quarter | `Q1 2025` or `Q4 2024` | Specific quarter |
| Half year | `H1 2025` or `H2 2024` | First or second half of year |
| Last quarter | `last quarter` | Previous complete quarter |
| Last year | `last year` | Previous 12 months |

**Examples:**
```
/customer-report REWE
/customer-report "Deutsche Bahn" 6
/customer-report Lidl Q4 2024
/customer-report REWE 2024-01-01 2024-12-31
/customer-report "Deutsche Bahn" YTD
/customer-report Lidl H1 2025
/customer-report REWE last quarter
```

## Workflow

### Step 1: Parse Parameters

Parse $ARGUMENTS to extract:
- `account_name`: Required - the customer name to search for
- `timeframe`: Optional - time period specification (default: 12 months)

**Timeframe Parsing Logic:**

1. **Number only** (e.g., `6`, `12`, `24`):
   - `start_date` = CURRENT_DATE - INTERVAL '{N} months'
   - `end_date` = CURRENT_DATE

2. **Date range** (e.g., `2024-06-01 2025-01-31`):
   - `start_date` = first date
   - `end_date` = second date

3. **Month range** (e.g., `Jun2024 Jan2025`):
   - Parse month abbreviations: Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec
   - `start_date` = first day of start month
   - `end_date` = last day of end month

4. **YTD** (Year to Date):
   - `start_date` = January 1 of current year
   - `end_date` = CURRENT_DATE

5. **Quarter** (e.g., `Q1 2025`, `Q4 2024`):
   - Q1: Jan 1 - Mar 31
   - Q2: Apr 1 - Jun 30
   - Q3: Jul 1 - Sep 30
   - Q4: Oct 1 - Dec 31

6. **Half year** (e.g., `H1 2025`, `H2 2024`):
   - H1: Jan 1 - Jun 30
   - H2: Jul 1 - Dec 31

7. **Last quarter**:
   - Calculate previous complete quarter from current date

8. **Last year**:
   - `start_date` = CURRENT_DATE - INTERVAL '12 months'
   - `end_date` = CURRENT_DATE

### Step 2: Search for Account

Run this query to find the ultimate parent company name:

```sql
SELECT DISTINCT ultimate_parent_company_name
FROM rds.rep_job_metrics
WHERE ultimate_parent_company_name ILIKE '%{account_name}%'
  AND date_dt >= '{start_date}'
  AND date_dt <= '{end_date}'
LIMIT 10
```

If multiple matches found, ask user to select the correct one.

### Step 3: Query Total Metrics

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
  AND date_dt >= '{start_date}'
  AND date_dt <= '{end_date}'
  AND product_type IN ('Reach', 'Hire')
GROUP BY product_type
ORDER BY product_type
```

### Step 4: Query Monthly CPA Trending

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
  AND date_dt >= '{start_date}'
  AND date_dt <= '{end_date}'
  AND product_type IN ('Reach', 'Hire')
GROUP BY product_type, DATE_TRUNC('month', date_dt)
ORDER BY product_type, month
```

### Step 5: Query Monthly Applications Trending

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
  AND date_dt >= '{start_date}'
  AND date_dt <= '{end_date}'
  AND product_type IN ('Reach', 'Hire')
GROUP BY product_type, DATE_TRUNC('month', date_dt)
ORDER BY product_type, month
```

### Step 6: Query Budget Data

```sql
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

### Step 7: Generate Report Data JSON

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
        "monthly_cpa": [["02/25", 9.25, 6830], ["04/25", 11.23, 6950], ["06/25", 8.50, 7200]],
        "monthly_apps": [["02/25", 26502, 8213], ["04/25", 20753, 7286], ["06/25", 22100, 7500]]
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
        "monthly_cpa": [["02/25", 65.14, 87], ["04/25", 51.44, 75], ["06/25", 55.00, 80]],
        "monthly_apps": [["02/25", 3809, 565], ["04/25", 3178, 676], ["06/25", 3500, 620]]
    }
}
```

### Step 8: Generate PowerPoint

**Option A: Using Python generator (default)**

Save the JSON data to a temp file and run:

```bash
python3 ~/.claude/skills/customer-report/customer_report_generator.py /path/to/data.json ~/Desktop/Template.pptx ~/Desktop/{AccountName}_Customer_Report.pptx
```

**Option B: Using pptx skill with PptxGenJS (if Node.js available)**

If Node.js is installed, you can use the pptx skill's PptxGenJS approach.
See `~/.claude/skills/pptx/pptxgenjs.md` for the full reference.

**Option C: Using pptx skill template editing**

For advanced customization using an existing template:
1. Analyze template: `python ~/.claude/skills/pptx/scripts/thumbnail.py template.pptx`
2. Unpack: `python ~/.claude/skills/pptx/scripts/office/unpack.py template.pptx unpacked/`
3. Edit XML slides directly
4. Clean: `python ~/.claude/skills/pptx/scripts/clean.py unpacked/`
5. Pack: `python ~/.claude/skills/pptx/scripts/office/pack.py unpacked/ output.pptx --original template.pptx`

See `~/.claude/skills/pptx/editing.md` for the full workflow.

### Step 9: Report to User

Tell the user where the report was saved and provide a summary of the key metrics.

## Slide Structure

1. **Title Slide** - Account name, subtitle, date range
2. **Executive Summary** - KPI boxes with totals (Budget, CPA, Jobs, Applications)
3. **Section: Budget Overview**
4. **Budget Details** - Tables comparing REACH vs HIRE budgets and performance
5. **Section: REACH Performance**
6. **REACH CPA Chart** - Line chart with monthly CPA trending
7. **REACH Applications Chart** - Line chart with applications started/sent
8. **Section: HIRE Performance**
9. **HIRE CPA Chart** - Line chart with monthly CPA trending
10. **HIRE Applications Chart** - Line chart with applications started/sent
11. **Section: Performance Summary**
12. **Summary Dashboard** - Side-by-side KPI comparison

## Design Guidelines

Following the pptx skill's design principles:

### Color Palette (HeyJobs Brand)
| Role | Color | Hex |
|------|-------|-----|
| Primary | Purple | `662D91` |
| Dark | Charcoal | `333333` |
| Gray | Medium Gray | `808080` |
| Accent 1 | Coral | `FF5733` |
| Accent 2 | Teal | `00BFA5` |
| Light Purple | Pastel | `B4A0C8` |
| Light Blue | Pastel | `A0B4D2` |
| Light Green | Pastel | `A0D2B4` |
| Light Orange | Pastel | `F0B48C` |

### Design Principles
- **Don't create boring slides** - Use KPI boxes, charts, and varied layouts
- **Dark/light contrast** - Dark backgrounds for section headers, light for content
- **Commit to a visual motif** - Rounded KPI boxes with pastel backgrounds
- **Charts should be clean** - Subtle gridlines, modern styling

## Chart X-Axis Labels

For better readability on charts:
- Use `MM/YY` format (e.g., "02/25", "04/25", "06/25")
- Show every other month to reduce clutter (e.g., Feb, Apr, Jun, Aug, Oct, Dec)
- Always include the year to distinguish between years (e.g., "02/25" vs "02/26")
- For 12-month reports: ~7 data points
- For 6-month reports: ~4 data points
- For 24-month reports: ~12 data points

## Requirements

- Access to Redshift MCP tools (cluster: `main-dwh`, database: `snowplow`)
- Python 3 with `python-pptx` package
- Template at `~/Desktop/Template.pptx` (optional, uses blank if not found)

## Output

The report is saved to `~/Desktop/[AccountName]_Customer_Report.pptx`
