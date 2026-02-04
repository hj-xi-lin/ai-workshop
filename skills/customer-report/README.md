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
- **Redshift MCP plugin** configured with access to:
  - `rds.rep_job_metrics`
  - `rds.rep_accounting`
- **Python 3** with `python-pptx` package

## 💻 Usage

In Claude Code, use the skill with:

```bash
# Basic usage (last 12 months)
/customer-report REWE

# Specify time range (last 6 months)
/customer-report "Deutsche Bahn" 6

# Different account
/customer-report Lidl 24
```

**Parameters:**
| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `account_name` | Yes | - | Customer name (partial match supported) |
| `months` | No | 12 | Number of months to analyze |

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
| 13 | Closing slide |

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

## 🎨 Integration with pptx Skill

This skill integrates with Anthropic's `pptx` skill for enhanced PowerPoint capabilities:

- **Template-based editing**: Use unpack/edit/pack workflow for advanced customization
- **PptxGenJS**: Create presentations from scratch with JavaScript (requires Node.js)
- **Design guidelines**: Follows pptx skill's design principles for professional output

To install the pptx skill:
```bash
git clone https://github.com/anthropics/skills.git /tmp/anthropic-skills
cp -r /tmp/anthropic-skills/skills/pptx ~/.claude/skills/
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

## 📞 Support

For questions or issues, contact: xi.lin@heyjobs.de
