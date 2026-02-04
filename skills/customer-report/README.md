# 📊 Customer Report Skill for Claude Code

Generate comprehensive customer performance reports with REACH/HIRE split analysis directly from Claude Code.

## 🎯 What It Does

This skill allows you to generate a professional PowerPoint presentation for any customer account by simply typing:

```
/customer-report REWE
```

The generated report includes:
- Executive summary with 8 key KPIs
- Budget overview (REACH vs HIRE)
- Monthly CPA trending charts
- Monthly applications trending charts
- Performance comparison dashboard

## 🚀 Quick Install

```bash
# Clone this repo
git clone https://github.com/hj-xi-lin/ai-workshop.git

# Navigate to skill folder
cd ai-workshop/skills/customer-report

# Run installer
chmod +x install.sh
./install.sh
```

## 📋 Requirements

- **Claude Code** CLI installed
- **AWS SSO** access configured (run `aws sso login --profile redshift_mcp` before use)
- **Redshift MCP plugin** configured with access to:
  - `rds.rep_job_metrics`
  - `rds.rep_accounting`
- **Python 3** with `python-pptx` package

## 💻 Usage

In Claude Code, use the skill with:

```bash
# Basic usage (last 12 months)
/customer-report REWE

# Specify number of months
/customer-report "Deutsche Bahn" 6

# Specific date range
/customer-report REWE 2024-01-01 2024-12-31

# Year to date
/customer-report Lidl YTD

# Specific quarter
/customer-report REWE Q4 2024

# Half year
/customer-report "Deutsche Bahn" H1 2025

# Last quarter
/customer-report Lidl last quarter
```

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

**Parameters:**
| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `account_name` | Yes | - | Customer name (partial match supported) |
| `timeframe` | No | 12 months | Time period (see formats above) |

## 📑 Report Structure

| Slide | Content |
|-------|---------|
| 1 | Title with account name and date range |
| 2 | Executive Summary (KPIs + REACH/HIRE comparison) |
| 3 | Section: Budget Overview |
| 4 | Budget tables by Product + Performance comparison |
| 5 | Section: REACH Performance |
| 6 | REACH CPA Trending (line chart) |
| 7 | REACH Applications Trending (line chart) |
| 8 | Section: HIRE Performance |
| 9 | HIRE CPA Trending (line chart) |
| 10 | HIRE Applications Trending (line chart) |
| 11 | Section: Performance Summary |
| 12 | Summary Dashboard (REACH vs HIRE side-by-side) |

## 📁 Files Included

| File | Description |
|------|-------------|
| `SKILL.md` | Main skill file with instructions (Claude Code format) |
| `customer_report_generator.py` | Python script for PowerPoint generation |
| `Template.pptx` | HeyJobs PowerPoint template |
| `install.sh` | One-click installation script |

## 🔧 Manual Installation

If the install script doesn't work, manually copy files:

```bash
# Create skills directory with proper structure
mkdir -p ~/.claude/skills/customer-report

# Copy skill files
cp SKILL.md ~/.claude/skills/customer-report/
cp customer_report_generator.py ~/.claude/skills/customer-report/

# Copy template to Desktop
cp Template.pptx ~/Desktop/

# Install Python dependency
pip3 install python-pptx
```

## 📤 Output

Reports are saved to: `~/Desktop/[AccountName]_Customer_Report.pptx`

## 🎨 Customization

To customize the report style, edit `customer_report_generator.py`:

- **Colors**: Modify `HEYJOBS_*` and `LIGHT_*` color variables
- **Layout**: Adjust `Inches()` values for positioning
- **Labels**: Update German text strings

## ❓ Troubleshooting

**"python-pptx not found"**
```bash
pip3 install python-pptx
```

**"Template not found"**
```bash
cp Template.pptx ~/Desktop/
```

**"No data found for account"**
- Check the account name spelling
- Verify you have Redshift MCP access
- Try a partial name match (e.g., "Bahn" instead of "Deutsche Bahn")

**"Unknown skill: customer-report"**
- Ensure files are in `~/.claude/skills/customer-report/SKILL.md` (not directly in skills folder)
- Restart Claude Code after installation

**"AWS credentials error"**
```bash
aws sso login --profile redshift_mcp
```

## 📞 Support

For questions or issues, contact: xi.lin@heyjobs.de
