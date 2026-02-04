# AI Workshop - Claude Code Configuration

## Custom Skills

### /customer-report

Generate a customer performance report with REACH/HIRE split.

See `skills/customer-report/SKILL.md` for full documentation.

**Usage:** `/customer-report [account_name] [timeframe]`

**Supported Timeframe Formats:**
- Number: `12` (last N months)
- Date range: `2024-06-01 2025-01-31`
- Month range: `Jun2024 Jan2025`
- YTD: `YTD` (year to date)
- Quarter: `Q1 2025`, `Q4 2024`
- Half year: `H1 2025`, `H2 2024`
- Last quarter: `last quarter`
- Last year: `last year`

**Examples:**
- `/customer-report REWE` - Last 12 months (default)
- `/customer-report "Deutsche Bahn" 6` - Last 6 months
- `/customer-report Lidl Q4 2024` - Q4 2024 only
- `/customer-report REWE 2024-01-01 2024-12-31` - Full year 2024
- `/customer-report "Deutsche Bahn" YTD` - Year to date
