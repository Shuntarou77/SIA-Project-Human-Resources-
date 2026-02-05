# Payslip PDF Design Specification

## Visual Layout

The payslip PDF is designed to match professional payroll standards with the following structure:

### Header Section
```
┌─────────────────────────────────────────────────────┐
│     ESSENTIALS BEAUTY PRODUCT COMPANY                │
│                  PAYSLIP                             │
│        Pay Period: [Start Date] - [End Date]         │
│        Pay Date: [Payment Date]                      │
└─────────────────────────────────────────────────────┘
```

### Employee Information Grid
```
┌──────────────────────┬──────────────────────┐
│ Employee ID          │ Employee Name        │
│ [ID Number]          │ [Full Name]          │
├──────────────────────┼──────────────────────┤
│ Department           │ Position             │
│ [Department Name]    │ [Job Title]          │
└──────────────────────┴──────────────────────┘
```

### Earnings & Deductions Table
```
┌──────────────────┬──────────┬──────────────────┬──────────┐
│ EARNINGS         │  AMOUNT  │ DEDUCTIONS       │  AMOUNT  │
├──────────────────┼──────────┼──────────────────┼──────────┤
│ Basic Salary     │ ₱X,XXX.XX│ SSS              │ ₱XXX.XX  │
│ Allowances       │ ₱X,XXX.XX│ PhilHealth       │ ₱XXX.XX  │
│ Overtime Pay     │ ₱X,XXX.XX│ Pag-IBIG         │ ₱XXX.XX  │
│ Holiday Pay      │ ₱X,XXX.XX│ Withholding Tax  │ ₱XXX.XX  │
│ Night Differential│ ₱X,XXX.XX│ SSS Loan         │ ₱XXX.XX  │
│ Bonuses          │ ₱X,XXX.XX│ Pag-IBIG Loan    │ ₱XXX.XX  │
│ Other Earnings   │ ₱X,XXX.XX│ Company Loan     │ ₱XXX.XX  │
│                  │          │ Absence Penalty  │ ₱XXX.XX  │
│                  │          │ Late Penalty     │ ₱XXX.XX  │
│                  │          │ Other Deductions │ ₱XXX.XX  │
├──────────────────┼──────────┼──────────────────┼──────────┤
│ TOTAL EARNINGS   │ ₱X,XXX.XX│ TOTAL DEDUCTIONS │ ₱XXX.XX  │
└──────────────────┴──────────┴──────────────────┴──────────┘
```

### Net Salary (Highlighted)
```
┌─────────────────────────────────────────────────────┐
│         NET SALARY: ₱XX,XXX.XX                      │
└─────────────────────────────────────────────────────┘
```

### Footer
```
┌─────────────────────────────────────────────────────┐
│ This is a computer-generated payslip and does not   │
│ require a signature.                                │
│ Generated on: [Date and Time]                       │
└─────────────────────────────────────────────────────┘
```

## Color Scheme

- **Primary Color**: #A36A66 (Mauve/Rose Brown)
  - Used for: Headers, company name, borders, net salary background
- **Background Colors**:
  - White (#FFFFFF) - Main background
  - Light Gray (#F5F5F5) - Employee info boxes
  - Light Rose (#F8ECEB) - Highlights
- **Text Colors**:
  - Dark Gray (#333333) - Main text
  - Medium Gray (#666666) - Secondary text
  - White (#FFFFFF) - Text on colored backgrounds

## Typography

- **Font Family**: Segoe UI, Arial, sans-serif
- **Font Sizes**:
  - Company Name: 24px (bold)
  - Payslip Title: 20px (bold)
  - Section Headers: 12px (bold, uppercase)
  - Regular Text: 11-13px
  - Net Salary: 18px (bold)
  - Footer: 10px

## Page Specifications

- **Page Size**: A4 (210mm × 297mm)
- **Orientation**: Portrait
- **Margins**: 20px on all sides
- **Content Width**: 1024px (optimized for PDF)

## Key Features

### 1. Professional Appearance
- Clean, organized layout
- Consistent spacing and alignment
- Professional color scheme matching company branding
- Clear hierarchy of information

### 2. Comprehensive Information
- All earnings itemized
- All deductions itemized
- Clear totals
- Employee identification
- Pay period clearly stated

### 3. Readability
- High contrast text
- Adequate font sizes
- Logical grouping of information
- Clear labels and headers

### 4. Branding
- Company name prominently displayed
- Consistent use of brand colors
- Professional footer with generation timestamp

## Example Payslip Content

```
═══════════════════════════════════════════════════════
    ESSENTIALS BEAUTY PRODUCT COMPANY
                PAYSLIP
    Pay Period: November 16-30, 2024
    Pay Date: December 05, 2024
═══════════════════════════════════════════════════════

┌──────────────────────┬──────────────────────┐
│ EMPLOYEE ID          │ EMPLOYEE NAME        │
│ 23-2211              │ Dela Cruz, Juan M.   │
├──────────────────────┼──────────────────────┤
│ DEPARTMENT           │ POSITION             │
│ Sales                │ Sales Associate      │
└──────────────────────┴──────────────────────┘

┌──────────────────┬──────────┬──────────────────┬──────────┐
│ EARNINGS         │  AMOUNT  │ DEDUCTIONS       │  AMOUNT  │
├──────────────────┼──────────┼──────────────────┼──────────┤
│ Basic Salary     │ ₱15,000.00│ SSS             │ ₱581.30  │
│ Allowances       │ ₱2,000.00│ PhilHealth       │ ₱225.00  │
│ Overtime Pay     │ ₱1,500.00│ Pag-IBIG         │ ₱100.00  │
│ Holiday Pay      │ ₱0.00    │ Withholding Tax  │ ₱1,234.56│
│ Night Differential│ ₱0.00    │ SSS Loan         │ ₱0.00    │
│ Bonuses          │ ₱0.00    │ Pag-IBIG Loan    │ ₱0.00    │
│ Other Earnings   │ ₱0.00    │ Company Loan     │ ₱0.00    │
│                  │          │ Absence Penalty  │ ₱0.00    │
│                  │          │ Late Penalty     │ ₱0.00    │
│                  │          │ Other Deductions │ ₱0.00    │
├──────────────────┼──────────┼──────────────────┼──────────┤
│ TOTAL EARNINGS   │ ₱18,500.00│ TOTAL DEDUCTIONS│ ₱2,140.86│
└──────────────────┴──────────┴──────────────────┴──────────┘

╔═══════════════════════════════════════════════════╗
║         NET SALARY: ₱16,359.14                    ║
╚═══════════════════════════════════════════════════╝

───────────────────────────────────────────────────────
This is a computer-generated payslip and does not
require a signature.
Generated on: December 04, 2024 12:06 PM
───────────────────────────────────────────────────────
```

## Email Attachment Details

- **Filename Format**: `Payslip_[EmployeeID]_[StartDate]-[EndDate].pdf`
- **Example**: `Payslip_23-2211_20241116-20241130.pdf`
- **File Size**: Typically 50-100 KB per payslip
- **MIME Type**: application/pdf

## Accessibility

- High contrast ratios for text readability
- Clear font sizes (minimum 10px)
- Logical reading order
- Structured layout for screen readers
- Professional appearance suitable for printing

## Print Specifications

When printed on A4 paper:
- All content fits on one page
- Margins are appropriate for standard printers
- Text is clearly readable
- Colors print well in both color and grayscale
- Professional appearance suitable for employee records
