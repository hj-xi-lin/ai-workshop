# AI Workshop - Claude Code Configuration

## Custom Skills

### /customer-report

Generate a customer performance report with REACH/HIRE split.

**Usage:** `/customer-report [account_name] [months]`

**Examples:**
- `/customer-report REWE` - Last 12 months
- `/customer-report "Deutsche Bahn" 6` - Last 6 months

**When this skill is invoked, follow these steps:**

1. **Search for the account** in Redshift:
```sql
SELECT DISTINCT ultimate_parent_company_name, COUNT(DISTINCT job_id) as jobs
FROM rds.rep_job_metrics
WHERE ultimate_parent_company_name ILIKE '%{account_name}%'
  AND date_dt >= CURRENT_DATE - INTERVAL '{months} months'
GROUP BY ultimate_parent_company_name
ORDER BY jobs DESC LIMIT 10
```

2. **Query metrics by product type** (REACH/HIRE):
```sql
SELECT product_type,
    COUNT(DISTINCT job_id) as total_jobs,
    SUM(pageviews) as total_pageviews,
    SUM(active_application_start_count + passive_application_start_count) as applications_started,
    SUM(active_application_sent_count + passive_application_sent_count) as applications_sent,
    SUM(net_revenue_eur) as total_spend_eur,
    ROUND(CASE WHEN SUM(active_application_sent_count + passive_application_sent_count) > 0
        THEN SUM(net_revenue_eur) / SUM(active_application_sent_count + passive_application_sent_count)
        ELSE 0 END, 2) as avg_cpa_eur
FROM rds.rep_job_metrics
WHERE ultimate_parent_company_name = '{account_name}'
  AND date_dt >= CURRENT_DATE - INTERVAL '{months} months'
  AND product_type IN ('Reach', 'Hire')
GROUP BY product_type
```

3. **Query monthly trending** for CPA and applications

4. **Generate PowerPoint** using the template at `~/Desktop/Template.pptx` and Python script at `~/.claude/skills/customer_report_generator.py`

5. **Save report** to `~/Desktop/{AccountName}_Customer_Report.pptx`
