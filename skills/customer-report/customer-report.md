# Customer Performance Report Generator

Generate comprehensive customer performance reports with REACH/HIRE split analysis.

## Usage

```
/customer-report [account_name] [months]
```

**Parameters:**
- `account_name` (required): The ultimate parent company name to analyze (e.g., "REWE", "Deutsche Bahn")
- `months` (optional): Number of months to analyze (default: 12)

**Examples:**
```
/customer-report REWE
/customer-report "Deutsche Bahn" 6
/customer-report Lidl 24
```

## What This Skill Does

1. **Searches for the account** in the Redshift database by ultimate parent company name
2. **Queries performance data** split by REACH and HIRE products:
   - Budget overview (booked, used, available)
   - Jobs published
   - Page views
   - Applications started/sent
   - CPA metrics
   - Monthly trending data
3. **Generates a PowerPoint presentation** using the HeyJobs template with:
   - Executive summary
   - Budget overview by product
   - REACH performance section (CPA + Applications charts)
   - HIRE performance section (CPA + Applications charts)
   - Performance summary dashboard

## Requirements

- Access to Redshift MCP tools
- HeyJobs PowerPoint template at `~/Desktop/Template.pptx`
- Python with `python-pptx` package

## Output

The report is saved to `~/Desktop/[AccountName]_Customer_Report.pptx`
