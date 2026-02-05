<%@ Page Title="" Language="C#" MasterPageFile="~/webpage/HR.Master" AutoEventWireup="true" Async="true" EnableEventValidation="false" CodeBehind="Recruitment.aspx.cs" Inherits="ExWebAppSia.webpage.WebForm5" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
    :root {
        --primary-color: #A36A66;
        --primary-light: #C49A99;
     --primary-dark: #8B5A58;
      --success-color: #4CAF50;
        --danger-color: #E57373;
        --warning-color: #FFB74D;
        --text-primary: #2C3E50;
      --text-secondary: #7F8C8D;
  --bg-light: #F8F9FA;
        --bg-white: #FFFFFF;
        --border-color: #E0E0E0;
    --shadow-sm: 0 2px 4px rgba(0,0,0,0.08);
 --shadow-md: 0 4px 12px rgba(0,0,0,0.1);
    --shadow-lg: 0 8px 24px rgba(0,0,0,0.12);
    }

    * {
        margin: 0;
      padding: 0;
        box-sizing: border-box;
    }

    body {
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
        background: linear-gradient(135deg, #F8F9FA 0%, #E8EAED 100%);
        color: var(--text-primary);
    }

    .recruitment-container {
        max-width: 1400px;
        margin: 0 auto;
        padding: 32px 24px;
    }

    /* Modern Add Button with Icon */
    .add-applicant-button {
      display: inline-flex;
align-items: center;
        gap: 10px;
        background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
     color: white;
 border: none;
        padding: 14px 28px;
        border-radius: 12px;
  font-size: 15px;
        font-weight: 600;
        cursor: pointer;
        box-shadow: var(--shadow-md);
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      margin-bottom: 24px;
    }

    .add-applicant-button:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(163, 106, 102, 0.3);
    }

    .add-applicant-button:active {
        transform: translateY(0);
    }

  /* Stat Cards with Icons */
    .stat-cards {
   display: grid;
        grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
        gap: 20px;
        margin-bottom: 32px;
    }

    .stat-card {
        background: var(--bg-white);
 border-radius: 16px;
      padding: 24px;
        box-shadow: var(--shadow-sm);
        border: 1px solid var(--border-color);
        transition: all 0.3s ease;
        position: relative;
        overflow: hidden;
    }

    .stat-card::before {
        content: '';
        position: absolute;
top: 0;
        left: 0;
        width: 100%;
        height: 4px;
        background: linear-gradient(90deg, var(--primary-color), var(--primary-light));
    }

    .stat-card:hover {
        transform: translateY(-4px);
        box-shadow: var(--shadow-md);
    }

    .stat-card-content {
        display: flex;
        align-items: center;
        gap: 20px;
    }

  .stat-icon {
        width: 56px;
        height: 56px;
        background: linear-gradient(135deg, var(--primary-light), var(--primary-color));
        border-radius: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }

    .stat-icon svg {
   width: 28px;
        height: 28px;
        stroke: white;
 fill: none;
      stroke-width: 2;
     stroke-linecap: round;
        stroke-linejoin: round;
}

    .stat-info {
        flex: 1;
    }

    .stat-number {
        font-size: 32px;
        font-weight: 700;
        color: var(--text-primary);
      line-height: 1;
      margin-bottom: 6px;
    }

    .stat-label {
        font-size: 14px;
     font-weight: 500;
        color: var(--text-secondary);
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    /* Main Content Grid */
    .main-panels {
     display: grid;
        grid-template-columns: 1fr 1fr;
   gap: 24px;
 }

    /* Panel Styling */
    .panel {
        background: var(--bg-white);
        border-radius: 16px;
        padding: 0;
        box-shadow: var(--shadow-sm);
        border: 1px solid var(--border-color);
    display: flex;
   flex-direction: column;
     overflow: hidden;
    }

    .panel-header {
      background: var(--primary-color);
  color: white;
        padding: 20px 24px;
        display: flex;
        align-items: center;
  gap: 12px;
     font-size: 18px;
        font-weight: 600;
    }

    .panel-header svg {
        width: 24px;
  height: 24px;
        stroke: white;
     fill: none;
        stroke-width: 2;
  }

    .panel-body {
        padding: 24px;
   flex: 1;
    }

    /* Elegant Sub-Tabs */
    .sub-tabs {
        display: flex;
        gap: 4px;
        margin-bottom: 24px;
        background: var(--bg-light);
        padding: 6px;
    border-radius: 12px;
    }

    .sub-tab {
        flex: 1;
        padding: 12px 20px;
 border: none;
        background: transparent;
        color: var(--text-secondary);
    font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        border-radius: 8px;
        transition: all 0.3s ease;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
    }

    .sub-tab:hover {
        background: rgba(163, 106, 102, 0.1);
        color: var(--primary-color);
    }

    .sub-tab.active {
        background: var(--primary-color);
  color: white;
        box-shadow: var(--shadow-sm);
    }

    .tab-badge {
        background: rgba(255, 255, 255, 0.2);
        padding: 2px 8px;
        border-radius: 10px;
        font-size: 12px;
        font-weight: 700;
    }

    .sub-tab.active .tab-badge {
        background: rgba(255, 255, 255, 0.3);
  }

    .sub-tab:not(.active) .tab-badge {
        background: var(--primary-light);
color: white;
    }

    /* Modern Table */
    .applicant-table {
        width: 100%;
  border-collapse: separate;
 border-spacing: 0;
    }

    .applicant-table thead th {
        background: var(--bg-light);
        padding: 14px 16px;
    text-align: left;
        font-weight: 600;
   font-size: 13px;
        color: var(--text-secondary);
     text-transform: uppercase;
        letter-spacing: 0.5px;
        border-bottom: 2px solid var(--border-color);
    }

    .applicant-table tbody td {
        padding: 16px;
  border-bottom: 1px solid var(--border-color);
    font-size: 14px;
        color: var(--text-primary);
    }

    .applicant-table tbody tr {
        transition: all 0.2s ease;
    }

  .applicant-table tbody tr:hover {
      background: var(--bg-light);
    }

    /* Modern Action Buttons with Icons */
    .action-buttons {
        display: flex;
 gap: 8px;
      justify-content: center;
    }

    .btn {
     display: inline-flex;
      align-items: center;
 gap: 6px;
        padding: 8px 16px;
        border: none;
 border-radius: 8px;
    font-size: 13px;
    font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        white-space: nowrap;
  }

    .btn svg {
        width: 16px;
        height: 16px;
        stroke-width: 2;
    }

    .btn-view-details {
      background: var(--primary-color);
color: white;
    }

    .btn-view-details:hover {
        background: var(--primary-dark);
     transform: translateY(-1px);
        box-shadow: var(--shadow-sm);
    }

    .btn-approve {
        background: var(--success-color);
color: white;
    }

    .btn-approve:hover {
        background: #43A047;
        transform: translateY(-1px);
      box-shadow: var(--shadow-sm);
    }

    .btn-decline, .btn-not-hire {
        background: var(--danger-color);
        color: white;
    }

    .btn-decline:hover, .btn-not-hire:hover {
        background: #EF5350;
        transform: translateY(-1px);
        box-shadow: var(--shadow-sm);
    }

    .btn-hire {
        background: var(--success-color);
    color: white;
    }

    .btn-hire:hover {
        background: #43A047;
        transform: translateY(-1px);
        box-shadow: var(--shadow-sm);
    }

    .btn-hire:disabled {
      background: #BDBDBD;
        cursor: not-allowed;
        transform: none;
    }

    /* Status Badges */
    .status-badge {
        display: inline-flex;
     align-items: center;
        gap: 6px;
        padding: 6px 12px;
     border-radius: 20px;
        font-size: 12px;
        font-weight: 600;
    }

    .status-approved {
        background: #E8F5E9;
        color: #2E7D32;
    }

    .status-declined {
    background: #FFEBEE;
        color: #C62828;
    }

    /* Schedule Button */
    .schedule-button {
        display: inline-flex;
        align-items: center;
        gap: 10px;
  background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
   color: white;
        border: none;
    padding: 12px 24px;
        border-radius: 10px;
        font-size: 14px;
    font-weight: 600;
 cursor: pointer;
        margin-top: 20px;
        transition: all 0.3s ease;
    }

    .schedule-button:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
    }

    .schedule-button svg {
    width: 18px;
        height: 18px;
    }

    /* Select All */
    .select-all {
  display: flex;
        align-items: center;
        gap: 10px;
padding: 12px 16px;
     background: var(--bg-light);
        border-radius: 8px;
    margin-bottom: 16px;
    }

.select-all input[type="checkbox"] {
        width: 18px;
        height: 18px;
   cursor: pointer;
     accent-color: var(--primary-color);
    }

    .select-all label {
        font-size: 14px;
   font-weight: 500;
   color: var(--text-secondary);
        cursor: pointer;
    }

    /* Checkboxes */
 input[type="checkbox"].applicant-checkbox {
  width: 18px;
height: 18px;
     cursor: pointer;
        accent-color: var(--primary-color);
    }

    /* Empty State */
    .empty-state {
        text-align: center;
    padding: 48px 24px;
        color: var(--text-secondary);
    }

    .empty-state svg {
   width: 64px;
    height: 64px;
     stroke: var(--text-secondary);
        opacity: 0.3;
  margin-bottom: 16px;
    }

    /* Responsive */
    @media (max-width: 1024px) {
     .main-panels {
  grid-template-columns: 1fr;
        }
    }

  @media (max-width: 768px) {
        .recruitment-container {
  padding: 16px;
 }

        .stat-cards {
  grid-template-columns: 1fr;
        }

        .action-buttons {
      flex-direction: column;
        }

        .btn {
            width: 100%;
            justify-content: center;
        }
    }

    /* Panel Title */
  .panel-title {
        font-size: 16px;
        font-weight: 600;
     color: var(--text-primary);
    margin-bottom: 16px;
    padding-bottom: 12px;
        border-bottom: 2px solid var(--border-color);
    }

    /* Smooth Animations */
    .sub-tab-content {
        animation: fadeIn 0.3s ease;
    }

    @keyframes fadeIn {
    from {
opacity: 0;
     transform: translateY(10px);
        }
      to {
opacity: 1;
            transform: translateY(0);
   }
    }

    /* ========== MODERN MODAL STYLING ========== */
    .modal {
        display: none;
    position: fixed;
        z-index: 9999;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
 background: rgba(0, 0, 0, 0.7);
        backdrop-filter: blur(8px);
        animation: fadeIn 0.3s ease;
    }

  .modal-content {
 background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
      margin: 2% auto;
   width: 90%;
        max-width: 900px;
        border-radius: 24px;
  box-shadow: 0 20px 60px rgba(163, 106, 102, 0.3),
          0 0 0 1px rgba(163, 106, 102, 0.1);
        animation: slideUp 0.3s ease;
        max-height: 90vh;
 display: flex;
        flex-direction: column;
        position: relative;
        overflow: hidden;
    }

    /* Decorative corner accents */
    .modal-content::before,
    .modal-content::after {
        content: '';
      position: absolute;
    width: 120px;
        height: 120px;
    background: linear-gradient(135deg, rgba(163, 106, 102, 0.1), transparent);
        z-index: 0;
    }

    .modal-content::before {
        top: 0;
        left: 0;
        border-radius: 24px 0 100% 0;
    }

    .modal-content::after {
        bottom: 0;
        right: 0;
      border-radius: 0 0 24px 0;
        background: linear-gradient(315deg, rgba(163, 106, 102, 0.1), transparent);
    }

  @keyframes slideUp {
        from {
     transform: translateY(50px) scale(0.95);
 opacity: 0;
        }
    to {
            transform: translateY(0) scale(1);
     opacity: 1;
        }
    }

    .modal-header {
    background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
      color: white;
      padding: 28px 40px;
        border-radius: 24px 24px 0 0;
        display: flex;
        justify-content: space-between;
        align-items: center;
        position: relative;
        z-index: 1;
     box-shadow: 0 4px 20px rgba(163, 106, 102, 0.2);
    }

    /* Decorative header pattern */
    .modal-header::before {
        content: '';
        position: absolute;
    top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.05'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zM36 6V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
        opacity: 0.3;
        pointer-events: none;
    }

    .modal-title {
     font-size: 26px;
   font-weight: 700;
        margin: 0;
   position: relative;
     z-index: 1;
        display: flex;
        align-items: center;
 gap: 12px;
    }

    /* Add decorative icon to title */
    .modal-title::before {
        content: '';
    width: 6px;
        height: 36px;
        background: linear-gradient(180deg, white, rgba(255,255,255,0.5));
  border-radius: 3px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.2);
    }

    .close {
        color: white;
        font-size: 28px;
  font-weight: 300;
   cursor: pointer;
        transition: all 0.3s ease;
        width: 40px;
        height: 40px;
        display: flex;
 align-items: center;
        justify-content: center;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.1);
        backdrop-filter: blur(10px);
 position: relative;
      z-index: 1;
    }

  .close:hover {
 background: rgba(255, 255, 255, 0.2);
        transform: rotate(90deg) scale(1.1);
        box-shadow: 0 4px 12px rgba(0,0,0,0.2);
    }

    /* Modal Body Sections */
    #addApplicantForm {
        padding: 40px;
        position: relative;
        z-index: 1;
  background: transparent;
    }

    #addApplicantForm h3 {
        color: var(--primary-color);
        font-size: 22px;
        font-weight: 700;
   margin-bottom: 32px;
    padding-bottom: 16px;
        border-bottom: 3px solid transparent;
        background: linear-gradient(90deg, var(--primary-light), transparent) padding-box,
     linear-gradient(90deg, var(--primary-color), transparent) border-box;
        border-image: linear-gradient(90deg, var(--primary-color), transparent) 1;
        display: flex;
        align-items: center;
        gap: 12px;
 position: relative;
    }

    /* Decorative dot before h3 */
    #addApplicantForm h3::before {
  content: '';
        width: 12px;
 height: 12px;
 background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
        border-radius: 50%;
        box-shadow: 0 0 0 4px rgba(163, 106, 102, 0.2);
    }

    #addApplicantForm h4 {
        color: var(--primary-color);
        font-size: 17px;
        font-weight: 600;
 margin: 36px 0 24px 0;
        padding: 14px 20px;
     background: linear-gradient(90deg, rgba(163, 106, 102, 0.08), transparent);
        border-left: 4px solid var(--primary-color);
   border-radius: 0 12px 12px 0;
        position: relative;
        box-shadow: 0 2px 8px rgba(163, 106, 102, 0.08);
    }

    /* Decorative accent on h4 */
    #addApplicantForm h4::after {
        content: '';
        position: absolute;
        right: 20px;
        top: 50%;
        transform: translateY(-50%);
        width: 40px;
 height: 2px;
        background: linear-gradient(90deg, var(--primary-color), transparent);
 }

/* Form Groups */
    .form-group {
        margin-bottom: 24px;
 position: relative;
    }

    .form-group label {
      display: block;
   font-size: 14px;
     font-weight: 600;
        color: var(--text-primary);
  margin-bottom: 10px;
  transition: all 0.3s ease;
    }

  .form-group label:after {
   content: '*';
        color: var(--danger-color);
        margin-left: 4px;
        display: none;
    }

    .form-group label[for*="First"]:after,
    .form-group label[for*="Last"]:after,
    .form-group label[for*="Applied"]:after {
        display: inline;
    }

    .form-control {
        width: 100%;
  padding: 14px 18px;
        font-size: 14px;
        border: 2px solid transparent;
        background: white;
        border-radius: 12px;
        transition: all 0.3s ease;
        font-family: inherit;
        box-shadow: 0 2px 8px rgba(0,0,0,0.04);
    }

 .form-control:focus {
        outline: none;
        border-color: var(--primary-color);
        box-shadow: 0 0 0 4px rgba(163, 106, 102, 0.12),
           0 4px 12px rgba(163, 106, 102, 0.15);
        transform: translateY(-1px);
    }

  .form-control:hover:not(:focus) {
        border-color: var(--primary-light);
     box-shadow: 0 4px 12px rgba(0,0,0,0.08);
    }

    select.form-control {
   cursor: pointer;
 appearance: none;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 14 14'%3E%3Cpath fill='%23A36A66' d='M7 10L2 5h10z'/%3E%3C/svg%3E");
        background-repeat: no-repeat;
        background-position: right 18px center;
   padding-right: 48px;
    }

    textarea.form-control {
        resize: vertical;
     min-height: 90px;
        line-height: 1.6;
    }

    /* Elegant Checkboxes and Radio Buttons */
    input[type="checkbox"] {
        width: 22px;
     height: 22px;
        cursor: pointer;
        accent-color: var(--primary-color);
        margin-right: 10px;
        border-radius: 6px;
    }

    .contract-type-radio td {
        padding: 10px 20px 10px 0;
    }

    .contract-type-radio input[type="radio"] {
        width: 22px;
        height: 22px;
        cursor: pointer;
        accent-color: var(--primary-color);
        margin-right: 10px;
    }

    .contract-type-radio label {
        cursor: pointer;
        font-size: 15px;
        font-weight: 500;
    color: var(--text-primary);
        transition: color 0.3s ease;
    }

    .contract-type-radio label:hover {
      color: var(--primary-color);
    }

    /* Form Actions */
    .form-actions {
        display: flex;
        gap: 16px;
        justify-content: flex-end;
        padding-top: 32px;
        border-top: 2px solid transparent;
        background: linear-gradient(white, white) padding-box,
         linear-gradient(90deg, var(--border-color), transparent) border-box;
        border-image: linear-gradient(90deg, var(--border-color), transparent) 1 0 0 0;
        margin-top: 20px;
  }

    .btn-primary, .btn-secondary {
        padding: 14px 36px;
        border: none;
        border-radius: 12px;
        font-size: 15px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
    display: inline-flex;
        align-items: center;
  gap: 10px;
        position: relative;
        overflow: hidden;
    }

    .btn-primary::before,
    .btn-secondary::before {
        content: '';
        position: absolute;
        top: 50%;
        left: 50%;
        width: 0;
 height: 0;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.3);
        transform: translate(-50%, -50%);
        transition: width 0.6s, height 0.6s;
}

 .btn-primary:hover::before,
    .btn-secondary:hover::before {
        width: 300px;
        height: 300px;
    }

 .btn-primary {
        background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
        color: white;
        box-shadow: 0 4px 15px rgba(163, 106, 102, 0.3);
    }

 .btn-primary:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 25px rgba(163, 106, 102, 0.4);
    }

    .btn-primary:active {
  transform: translateY(0);
    }

    .btn-secondary {
        background: white;
        color: var(--text-primary);
        border: 2px solid var(--border-color);
      box-shadow: 0 2px 8px rgba(0,0,0,0.05);
    }

    .btn-secondary:hover {
        background: var(--bg-light);
        border-color: var(--primary-light);
      box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    }

/* Message Alerts */
    .message {
        display: none;
     padding: 18px 24px;
        margin: 24px 40px;
        border-radius: 12px;
        font-size: 14px;
        font-weight: 500;
        animation: slideDown 0.3s ease;
        position: relative;
   overflow: hidden;
    }

    .message::before {
        content: '';
   position: absolute;
        left: 0;
        top: 0;
        bottom: 0;
    width: 4px;
    }

    @keyframes slideDown {
   from {
         transform: translateY(-20px);
            opacity: 0;
        }
        to {
          transform: translateY(0);
            opacity: 1;
        }
    }

    .message.success {
   background: linear-gradient(135deg, #E8F5E9, #C8E6C9);
     color: #2E7D32;
        box-shadow: 0 4px 12px rgba(76, 175, 80, 0.2);
    }

    .message.success::before {
      background: linear-gradient(180deg, #4CAF50, #2E7D32);
    }

    .message.error {
        background: linear-gradient(135deg, #FFEBEE, #FFCDD2);
        color: #C62828;
        box-shadow: 0 4px 12px rgba(244, 67, 54, 0.2);
    }

    .message.error::before {
        background: linear-gradient(180deg, #E57373, #C62828);
    }

    /* Previous Company Section Toggle */
    #previousCompanySection {
        padding: 24px;
        background: linear-gradient(135deg, rgba(163, 106, 102, 0.03), rgba(163, 106, 102, 0.06));
 border-radius: 16px;
        margin-top: 20px;
   border: 2px dashed rgba(163, 106, 102, 0.3);
   position: relative;
        overflow: hidden;
    }

    #previousCompanySection::before {
        content: '';
        position: absolute;
 top: -50%;
        right: -50%;
 width: 200%;
        height: 200%;
  background: radial-gradient(circle, rgba(163, 106, 102, 0.05), transparent);
        animation: rotate 20s linear infinite;
    }

    @keyframes rotate {
        from { transform: rotate(0deg); }
 to { transform: rotate(360deg); }
    }

    /* Referral Name Section */
    #referralNameSection {
    padding: 20px;
  background: linear-gradient(135deg, rgba(163, 106, 102, 0.05), rgba(163, 106, 102, 0.08));
        border-radius: 12px;
        margin-top: 16px;
        border-left: 4px solid var(--primary-color);
   box-shadow: 0 2px 8px rgba(163, 106, 102, 0.1);
    }

    /* Schedule Interview Modal Specifics */
    #scheduleInterviewModal .modal-content {
        max-width: 700px;
    }

    #selectedApplicantsList {
  list-style: none;
        padding: 0;
      margin: 20px 0 0 0;
    }

    #selectedApplicantsList li {
   padding: 12px 20px;
        background: white;
     border-radius: 10px;
        margin-bottom: 10px;
        border-left: 4px solid var(--primary-color);
        font-weight: 500;
 box-shadow: 0 2px 8px rgba(163, 106, 102, 0.08);
        transition: all 0.3s ease;
    }

    #selectedApplicantsList li:hover {
        transform: translateX(4px);
    box-shadow: 0 4px 12px rgba(163, 106, 102, 0.15);
    }

    /* View Details Modal */
    #viewDetailsModal table {
        width: 100%;
        margin-bottom: 28px;
    }

    #viewDetailsModal table td {
        padding: 14px 20px;
        border-bottom: 1px solid rgba(163, 106, 102, 0.1);
    }

    #viewDetailsModal table tr:hover {
        background: rgba(163, 106, 102, 0.03);
    }

    #viewDetailsModal table td:first-child {
        font-weight: 600;
        color: var(--text-secondary);
     width: 40%;
    }

    /* Responsive Modal */
    @media (max-width: 768px) {
        .modal-content {
            width: 95%;
            margin: 5% auto;
            border-radius: 20px;
        }

        .modal-header {
   padding: 24px 28px;
    }

        .modal-title {
 font-size: 22px;
        }

        #addApplicantForm {
            padding: 28px 24px;
        }

        .form-actions {
            flex-direction: column-reverse;
 }

        .btn-primary, .btn-secondary {
            width: 100%;
         justify-content: center;
        }

        .modal-content::before,
        .modal-content::after {
            width: 80px;
       height: 80px;
 }
    }

</style>
    <script type="text/javascript">
        function openModal() {
            document.getElementById('addApplicantModal').style.display = 'block';
        }

        function closeModal() {
            document.getElementById('addApplicantModal').style.display = 'none';
            document.getElementById('messageDiv').style.display = 'none';
        }

        function openDetailsModal(applicantId) {
            // Load applicant details via AJAX or server-side
            var hiddenField = document.getElementById('<%= hdnApplicantId.ClientID %>');
            if (hiddenField) {
                hiddenField.value = applicantId;
            }
            var btn = document.getElementById('<%= btnViewDetails.ClientID %>');
            if (btn) {
                btn.click();
            }
        }

        function viewApplicantDetails(applicantId) {
            var hiddenField = document.getElementById('<%= hdnApplicantId.ClientID %>');
            if (hiddenField) {
                hiddenField.value = applicantId;
            }
            var btn = document.getElementById('<%= btnViewDetails.ClientID %>');
            if (btn) {
                btn.click();
            }
        }

        function hireApplicant(applicantId, buttonElement) {
            if (buttonElement) {
                buttonElement.disabled = true;
                buttonElement.textContent = 'Processing...';
            }
            var hiddenField = document.getElementById('<%= hdnApplicantId.ClientID %>');
            if (hiddenField) {
                hiddenField.value = applicantId;
            }
            var hireBtn = document.getElementById('<%= btnHireApplicant.ClientID %>');
            if (hireBtn) {
                hireBtn.click();
            }
            return false;
        }

        function notHireApplicant(applicantId, buttonElement) {
            if (buttonElement) {
                buttonElement.disabled = true;
                buttonElement.textContent = 'Processing...';
            }
            var hiddenField = document.getElementById('<%= hdnApplicantId.ClientID %>');
            if (hiddenField) {
                hiddenField.value = applicantId;
            }
            var notHireBtn = document.getElementById('<%= btnNotHireApplicant.ClientID %>');
            if (notHireBtn) {
                notHireBtn.click();
            }
            return false;
        }

        // Sub-Tab Switching
        function showSubTab(tabName) {
            // Hide all sub-tab contents
 document.getElementById('newApplicantsView').style.display = 'none';
            document.getElementById('approvedApplicantsView').style.display = 'none';
            document.getElementById('declinedApplicantsView').style.display = 'none';

     // Remove active class from all sub-tabs
        var tabs = document.querySelectorAll('.sub-tab');
        tabs.forEach(function(tab) {
          tab.classList.remove('active');
       });

 // Show selected tab content and mark tab as active
if (tabName === 'new') {
  document.getElementById('newApplicantsView').style.display = 'block';
             tabs[0].classList.add('active');
       } else if (tabName === 'approved') {
            document.getElementById('approvedApplicantsView').style.display = 'block';
      tabs[1].classList.add('active');
     } else if (tabName === 'declined') {
   document.getElementById('declinedApplicantsView').style.display = 'block';
       tabs[2].classList.add('active');
            }
        }

        // Approve Applicant
        function approveApplicant(applicantId, buttonElement) {
            if (buttonElement) {
    buttonElement.disabled = true;
   buttonElement.textContent = 'Processing...';
 }
            var hiddenField = document.getElementById('<%= hdnApplicantId.ClientID %>');
            if (hiddenField) {
            hiddenField.value = applicantId;
      }
            var approveBtn = document.getElementById('<%= btnApproveApplicant.ClientID %>');
       if (approveBtn) {
  approveBtn.click();
      }
            return false;
  }

        // Decline Applicant
        function declineApplicant(applicantId, buttonElement) {
            if (confirm('Are you sure you want to decline this applicant? A rejection email will be sent.')) {
        if (buttonElement) {
                buttonElement.disabled = true;
                buttonElement.textContent = 'Processing...';
            }
          var hiddenField = document.getElementById('<%= hdnApplicantId.ClientID %>');
         if (hiddenField) {
            hiddenField.value = applicantId;
       }
      var declineBtn = document.getElementById('<%= btnDeclineApplicant.ClientID %>');
  if (declineBtn) {
        declineBtn.click();
          }
       }
   return false;
   }

        // Update Select All for Approved tab
        function initializeSelectAllApproved() {
      var selectAllCheckbox = document.getElementById('selectAllApproved');
            if (selectAllCheckbox) {
          selectAllCheckbox.addEventListener('change', function() {
     var tableBody = document.getElementById('<%= approvedApplicantsTableBody.ClientID %>');
  if (tableBody) {
    var checkboxes = tableBody.querySelectorAll('input[type="checkbox"].applicant-checkbox');
       checkboxes.forEach(function(checkbox) {
   checkbox.checked = selectAllCheckbox.checked;
         });
       }
           });
  }
        }

// Initialize on page load
        if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() {
     initializeSelectAll();
           initializeSelectAllApproved();
 });
 } else {
      initializeSelectAll();
 initializeSelectAllApproved();
    }

        window.onclick = function(event) {
            var modal = document.getElementById('addApplicantModal');
            var detailsModal = document.getElementById('viewDetailsModal');
            var scheduleModal = document.getElementById('scheduleInterviewModal');
            if (event.target == modal) {
                closeModal();
            }
            if (event.target == detailsModal) {
                closeDetailsModal();
            }
            if (event.target == scheduleModal) {
                closeScheduleInterviewModal();
            }
        }

      function openScheduleInterviewModal() {
            // Get selected applicant IDs from Approved tab
  var tableBody = document.getElementById('<%= approvedApplicantsTableBody.ClientID %>');
          if (!tableBody) {
                alert('Unable to find applicants table. Please refresh the page.');
      return;
  }

            // Find all checkboxes in the approved applicants table
            var checkboxes = tableBody.querySelectorAll('input[type="checkbox"].applicant-checkbox');
        var checkedBoxes = [];
            
            checkboxes.forEach(function(checkbox) {
   if (checkbox.checked && checkbox.value) {
       checkedBoxes.push(checkbox);
         }
  });

          if (checkedBoxes.length === 0) {
      alert('Please select at least one approved applicant to schedule an interview.');
              return;
            }

var selectedIds = [];
            var selectedNames = [];

            checkedBoxes.forEach(function(checkbox) {
                if (checkbox.value) {
         selectedIds.push(checkbox.value);
  
         // Get applicant name from the row
      var row = checkbox.closest('tr');
           if (row) {
   var cells = row.getElementsByTagName('td');
        if (cells.length > 1) {
       var nameCell = cells[1]; // Name is in the second cell (index 1)
        if (nameCell) {
           selectedNames.push(nameCell.textContent.trim());
  }
          }
          }
     }
  });

  if (selectedIds.length === 0) {
    alert('Please select at least one approved applicant to schedule an interview.');
    return;
     }

   // Store selected IDs in hidden field
   document.getElementById('<%= hdnSelectedApplicantIds.ClientID %>').value = selectedIds.join(',');

         // Show selected applicants in modal
      var listElement = document.getElementById('selectedApplicantsList');
        if (listElement) {
     listElement.innerHTML = selectedNames.map(function(name) {
        return '<li>' + name + '</li>';
      }).join('');
         }

     // Show modal
  var modal = document.getElementById('scheduleInterviewModal');
            if (modal) {
       modal.style.display = 'block';
       }
        }

  // Toggle Previous Company Section
      function togglePreviousCompany() {
     var checkbox = document.getElementById('<%= chkPreviousCompany.ClientID %>');
  var section = document.getElementById('previousCompanySection');
       if (checkbox && section) {
   section.style.display = checkbox.checked ? 'block' : 'none';
 }
        }

        // Toggle Referral Name Section
   function toggleReferralName() {
      var dropdown = document.getElementById('<%= ddlHowDidYouHearUs.ClientID %>');
     var section = document.getElementById('referralNameSection');
        if (dropdown && section) {
          section.style.display = dropdown.value === 'Referral' ? 'block' : 'none';
         }
        }

     // Role Options by Department
        var rolesByDepartment = {
            "Research & Development": ["Research Scientist", "Lab Technician", "Product Developer", "R&D Manager"],
          "Quality Control": ["QC Analyst", "QC Inspector", "QC Manager", "Laboratory Supervisor"],
            "Human Resources": ["HR Generalist", "Recruitment Specialist", "HR Manager", "Training Coordinator"],
            "Finance": ["Accountant", "Financial Analyst", "Finance Manager", "Payroll Specialist"],
            "Marketing": ["Marketing Coordinator", "Brand Manager", "Digital Marketing Specialist", "Content Creator"],
            "IT Support": ["IT Support Specialist", "Network Administrator", "System Administrator", "IT Manager"],
            "Operations": ["Operations Coordinator", "Operations Manager", "Supply Chain Specialist", "Logistics Coordinator"],
            "Sales": ["Sales Representative", "Sales Manager", "Account Executive", "Business Development Manager"],
"Legal": ["Legal Counsel", "Compliance Officer", "Legal Assistant", "Contract Specialist"],
            "Customer Service": ["Customer Service Representative", "Customer Support Specialist", "Call Center Agent", "Customer Service Manager"]
    };

        // Update Role Dropdown Based on Department Selection
        function updateRoleOptions() {
            var deptDropdown = document.getElementById('<%= ddlAppliedPosition.ClientID %>');
   var roleDropdown = document.getElementById('ddlRoleClient');
        
       if (!deptDropdown || !roleDropdown) return;
            
    var selectedDept = deptDropdown.value;
        
      // Clear existing options
            roleDropdown.innerHTML = '<option value="">-- Select Role --</option>';
       
      if (selectedDept && rolesByDepartment[selectedDept]) {
       rolesByDepartment[selectedDept].forEach(function(role) {
    var option = document.createElement('option');
        option.value = role;
         option.textContent = role;
       roleDropdown.appendChild(option);
      });
    } else {
  roleDropdown.innerHTML = '<option value="">-- Select Department First --</option>';
            }
  
            // Clear hidden field
var hiddenField = document.getElementById('<%= hdnSelectedRole.ClientID %>');
  if (hiddenField) {
       hiddenField.value = '';
            }
        }

        // Update Hidden Role Field
   function updateRoleHiddenField() {
  var roleDropdown = document.getElementById('ddlRoleClient');
      var hiddenField = document.getElementById('<%= hdnSelectedRole.ClientID %>');
            
     if (roleDropdown && hiddenField) {
        hiddenField.value = roleDropdown.value;
    }
      }

  // Validate Add Applicant Form
        function validateAddApplicantForm() {
            var firstName = document.getElementById('<%= txtFirstName.ClientID %>').value.trim();
            var lastName = document.getElementById('<%= txtLastName.ClientID %>').value.trim();
       var appliedPosition = document.getElementById('<%= ddlAppliedPosition.ClientID %>').value;
   var role = document.getElementById('<%= hdnSelectedRole.ClientID %>').value;
      var howDidYouHearUs = document.getElementById('<%= ddlHowDidYouHearUs.ClientID %>').value;
            
        if (!firstName) {
  alert('Please enter First Name');
    return false;
     }
            
       if (!lastName) {
  alert('Please enter Last Name');
        return false;
      }
         
            if (!appliedPosition) {
   alert('Please select Applied Position (Department)');
        return false;
            }
        
        if (!role) {
                alert('Please select Role (Job Title)');
     return false;
            }
            
            if (!howDidYouHearUs) {
            alert('Please select How did you hear us?');
    return false;
        }
            
     return true;
        }

        // Close Details Modal
     function closeDetailsModal() {
            var modal = document.getElementById('viewDetailsModal');
  if (modal) {
       modal.style.display = 'none';
            }
        }

        // Close Schedule Interview Modal
   function closeScheduleInterviewModal() {
            var modal = document.getElementById('scheduleInterviewModal');
            if (modal) {
   modal.style.display = 'none';
        }
// Clear form
  document.getElementById('<%= txtInterviewDate.ClientID %>').value = '';
      document.getElementById('<%= txtInterviewTime.ClientID %>').value = '';
       document.getElementById('<%= txtInterviewLocation.ClientID %>').value = '';
            document.getElementById('<%= txtInterviewerName.ClientID %>').value = '';
            document.getElementById('<%= txtInterviewNotes.ClientID %>').value = '';
         document.getElementById('<%= hdnSelectedApplicantIds.ClientID %>').value = '';
        }

        // Validate Schedule Interview Form
     function validateScheduleInterviewForm() {
         var date = document.getElementById('<%= txtInterviewDate.ClientID %>').value;
 var time = document.getElementById('<%= txtInterviewTime.ClientID %>').value;
    var location = document.getElementById('<%= txtInterviewLocation.ClientID %>').value.trim();
var interviewer = document.getElementById('<%= txtInterviewerName.ClientID %>').value.trim();
       
            if (!date) {
      alert('Please select Interview Date');
    return false;
      }
            
    if (!time) {
        alert('Please select Interview Time');
         return false;
            }
            
            if (!location) {
     alert('Please enter Interview Location');
         return false;
   }
          
            if (!interviewer) {
          alert('Please enter Interviewer Name');
           return false;
        }
         
     return true;
  }

        // Initialize Select All (for future use)
        function initializeSelectAll() {
        // Placeholder for future implementation
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="recruitment-container">
        <!-- Modern Add Button with Icon -->
      <button type="button" class="add-applicant-button" onclick="openModal()">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" style="width: 20px; height: 20px;">
         <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
       </svg>
    Add New Applicant
      </button>

        <!-- Modern Stat Cards with Icons -->
        <div class="stat-cards">
 <div class="stat-card">
      <div class="stat-card-content">
           <div class="stat-icon">
            <svg viewBox="0 0 24 24" fill="none">
          <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
    <circle cx="12" cy="7" r="4"/>
              </svg>
      </div>
         <div class="stat-info">
       <div class="stat-number"><asp:Literal ID="litNewCount" runat="server" Text="0" /></div>
             <div class="stat-label">New Applicants</div>
      </div>
           </div>
            </div>
    <div class="stat-card">
       <div class="stat-card-content">
            <div class="stat-icon">
     <svg viewBox="0 0 24 24" fill="none">
             <path d="M9 11l3 3L22 4"/>
             <path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/>
       </svg>
 </div>
        <div class="stat-info">
       <div class="stat-number"><asp:Literal ID="litInProgressCount" runat="server" Text="0" /></div>
   <div class="stat-label">In-Progress</div>
  </div>
        </div>
      </div>
     </div>

        <!-- Main Content Panels -->
        <div class="main-panels">
     <!-- Left Panel: New Applicants -->
            <div class="panel">
      <div class="panel-header">
         <svg viewBox="0 0 24 24" fill="none">
 <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/>
  <circle cx="9" cy="7" r="4"/>
  <path d="M22 21v-2a4 4 0 0 0-3-3.87"/>
     <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
            </svg>
   New Applicants
              </div>
         <div class="panel-body">
    <!-- Elegant Sub-Tabs -->
    <div class="sub-tabs">
          <button type="button" class="sub-tab active" onclick="showSubTab('new')">
   New
          <span class="tab-badge"><asp:Literal ID="litNewSubCount" runat="server" Text="0" /></span>
        </button>
          <button type="button" class="sub-tab" onclick="showSubTab('approved')">
  Approved
       <span class="tab-badge"><asp:Literal ID="litApprovedCount" runat="server" Text="0" /></span>
  </button>
       <button type="button" class="sub-tab" onclick="showSubTab('declined')">
       Declined
<span class="tab-badge"><asp:Literal ID="litDeclinedCount" runat="server" Text="0" /></span>
                  </button>
  </div>

 <!-- New Applicants View -->
        <div id="newApplicantsView" class="sub-tab-content">
   <div class="panel-title">Applicants Awaiting Review</div>
           <table class="applicant-table">
          <thead>
          <tr>
      <th style="width: 40px;"></th>
            <th>Name</th>
        <th>Position</th>
         <th style="text-align: center;">Actions</th>
              </tr>
       </thead>
   <tbody id="newApplicantsTableBody" runat="server">
  <tr>
       <td colspan="4" class="empty-state">
           <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
       <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
     <circle cx="12" cy="7" r="4"/>
         </svg>
              <p>No new applicants found</p>
         </td>
         </tr>
       </tbody>
              </table>
           </div>

             <!-- Approved Applicants View -->
       <div id="approvedApplicantsView" class="sub-tab-content" style="display: none;">
  <div class="panel-title">Approved Applicants</div>
          <div class="select-all">
  <input type="checkbox" id="selectAllApproved" />
     <label for="selectAllApproved">Select All</label>
     </div>
<table class="applicant-table">
      <thead>
            <tr>
<th style="width: 40px;"></th>
           <th>Name</th>
            <th>Position</th>
           <th style="text-align: center;">Status</th>
       </tr>
        </thead>
            <tbody id="approvedApplicantsTableBody" runat="server">
        <tr>
           <td colspan="4" class="empty-state">
     <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M9 11l3 3L22 4"/>
       <path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/>
                  </svg>
       <p>No approved applicants found</p>
  </td>
      </tr>
                  </tbody>
     </table>
      <button type="button" class="schedule-button" onclick="openScheduleInterviewModal();">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
        <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
    <line x1="16" y1="2" x2="16" y2="6"/>
        <line x1="8" y1="2" x2="8" y2="6"/>
   <line x1="3" y1="10" x2="21" y2="10"/>
        </svg>
       Schedule Interview
     </button>
             </div>

 <!-- Declined Applicants View -->
       <div id="declinedApplicantsView" class="sub-tab-content" style="display: none;">
   <div class="panel-title">Declined Applicants</div>
       <table class="applicant-table">
   <thead>
           <tr>
 <th>Name</th>
 <th>Position</th>
  <th style="text-align: center;">Status</th>
    </tr>
      </thead>
    <tbody id="declinedApplicantsTableBody" runat="server">
    <tr>
       <td colspan="3" class="empty-state">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <circle cx="12" cy="12" r="10"/>
            <line x1="15" y1="9" x2="9" y2="15"/>
         <line x1="9" y1="9" x2="15" y2="15"/>
      </svg>
       <p>No declined applicants found</p>
      </td>
             </tr>
       </tbody>
                </table>
          </div>
    </div>
     </div>

            <!-- Right Panel: In-Progress Applicants -->
            <div class="panel">
    <div class="panel-header">
     <svg viewBox="0 0 24 24" fill="none">
        <circle cx="12" cy="12" r="10"/>
         <polyline points="12 6 12 12 16 14"/>
   </svg>
  In-Progress Applicants
      </div>
                <div class="panel-body">
            <table class="applicant-table">
        <thead>
           <tr>
            <th>Name</th>
    <th>Position</th>
      <th style="text-align: center;">Details</th>
      <th style="text-align: center;">Actions</th>
    </tr>
       </thead>
          <tbody id="inProgressApplicantsTableBody" runat="server">
    <tr>
         <td colspan="4" class="empty-state">
     <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
         <circle cx="12" cy="12" r="10"/>
        <polyline points="12 6 12 12 16 14"/>
           </svg>
               <p>No in-progress applicants found</p>
        </td>
       </tr>
    </tbody>
           </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Add Applicant Modal -->
    <div id="addApplicantModal" class="modal">
        <div class="modal-content">
  <div class="modal-header">
          <h2 class="modal-title">Add New Applicant</h2>
       <span class="close" onclick="closeModal()">&times;</span>
    </div>
 <div id="messageDiv" class="message" runat="server"></div>
     <div id="addApplicantForm" style="max-height: 80vh; overflow-y: auto;">
      <h3>
          Applicant Information
 </h3>
   
  <!-- Personal Info -->
         <div class="form-group">
     <label for="<%= txtFirstName.ClientID %>">First Name *</label>
      <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-control" placeholder="Enter first name"></asp:TextBox>
 </div>

    <div class="form-group">
        <label for="<%= txtMiddleName.ClientID %>">Middle Name</label>
  <asp:TextBox ID="txtMiddleName" runat="server" CssClass="form-control" placeholder="Enter middle name"></asp:TextBox>
  </div>
     
    <div class="form-group">
        <label for="<%= txtLastName.ClientID %>">Last Name *</label>
         <asp:TextBox ID="txtLastName" runat="server" CssClass="form-control" placeholder="Enter last name"></asp:TextBox>
  </div>

    <div class="form-group">
        <label for="<%= txtAge.ClientID %>">Age</label>
         <asp:TextBox ID="txtAge" runat="server" CssClass="form-control" TextMode="Number" placeholder="Enter age"></asp:TextBox>
  </div>

    <div class="form-group">
 <label for="<%= txtBirthDate.ClientID %>">Birthdate</label>
         <asp:TextBox ID="txtBirthDate" runat="server" CssClass="form-control" TextMode="Date" placeholder="dd/mm/yyyy"></asp:TextBox>
  </div>

    <div class="form-group">
      <label for="<%= ddlGender.ClientID %>">Gender</label>
        <asp:DropDownList ID="ddlGender" runat="server" CssClass="form-control">
         <asp:ListItem Value="">-- Select Gender --</asp:ListItem>
 <asp:ListItem Value="Male">Male</asp:ListItem>
    <asp:ListItem Value="Female">Female</asp:ListItem>
        </asp:DropDownList>
  </div>
     
<div class="form-group">
      <label for="<%= txtEmail.ClientID %>">Email Address</label>
         <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="email@example.com"></asp:TextBox>
       </div>

    <div class="form-group">
        <label for="<%= txtContactNo.ClientID %>">Contact No.</label>
         <asp:TextBox ID="txtContactNo" runat="server" CssClass="form-control" placeholder="Enter contact number"></asp:TextBox>
  </div>

    <div class="form-group">
        <label for="<%= txtAddress.ClientID %>">Address</label>
         <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" placeholder="Enter address"></asp:TextBox>
  </div>

    <div class="form-group">
        <label for="<%= txtEducation.ClientID %>">Education</label>
         <asp:TextBox ID="txtEducation" runat="server" CssClass="form-control" placeholder="Enter education background"></asp:TextBox>
  </div>

    <h4>Previous Company</h4>

    <div class="form-group">
     <asp:CheckBox ID="chkPreviousCompany" runat="server" Text="Has Previous Company" onclick="togglePreviousCompany();" />
    </div>

    <div id="previousCompanySection" style="display: none;">
        <div class="form-group">
     <label for="<%= txtCompanyName.ClientID %>">Company Name</label>
      <asp:TextBox ID="txtCompanyName" runat="server" CssClass="form-control" placeholder="Enter company name"></asp:TextBox>
      </div>

        <div class="form-group">
        <label for="<%= txtJobIndustry.ClientID %>">Job Industry</label>
        <asp:TextBox ID="txtJobIndustry" runat="server" CssClass="form-control" placeholder="Enter job industry"></asp:TextBox>
        </div>

        <div class="form-group">
   <label for="<%= txtYears.ClientID %>">Years</label>
     <asp:TextBox ID="txtYears" runat="server" CssClass="form-control" TextMode="Number" placeholder="Years of experience"></asp:TextBox>
      </div>

        <div class="form-group">
          <label for="<%= txtMonths.ClientID %>">Months</label>
   <asp:TextBox ID="txtMonths" runat="server" CssClass="form-control" TextMode="Number" placeholder="Months of experience"></asp:TextBox>
  </div>

        <div class="form-group">
  <label for="<%= txtPreviousPosition.ClientID %>">Previous Position</label>
<asp:TextBox ID="txtPreviousPosition" runat="server" CssClass="form-control" placeholder="Enter previous position"></asp:TextBox>
        </div>
    </div>

    <h4>Guardian Information</h4>

    <div class="form-group">
  <label for="<%= txtGuardianName.ClientID %>">Guardian Name</label>
       <asp:TextBox ID="txtGuardianName" runat="server" CssClass="form-control" placeholder="Enter guardian name"></asp:TextBox>
  </div>

    <div class="form-group">
        <label for="<%= txtGuardianContactNo.ClientID %>">Contact No.</label>
  <asp:TextBox ID="txtGuardianContactNo" runat="server" CssClass="form-control" placeholder="Enter guardian contact number"></asp:TextBox>
  </div>

    <div class="form-group">
        <label for="<%= txtGuardianEmail.ClientID %>">Email Address</label>
         <asp:TextBox ID="txtGuardianEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="Enter guardian email"></asp:TextBox>
  </div>

    <div class="form-group">
        <label for="<%= txtGuardianHomeAddress.ClientID %>">Home Address</label>
         <asp:TextBox ID="txtGuardianHomeAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" placeholder="Enter guardian home address"></asp:TextBox>
  </div>

    <h4>Application Information</h4>

 <!-- Application Information -->
          <div class="form-group">
      <label for="<%= ddlAppliedPosition.ClientID %>">Applied Position (Department) *</label>
    <asp:DropDownList ID="ddlAppliedPosition" runat="server" CssClass="form-control" onchange="updateRoleOptions();">
           <asp:ListItem Value="">-- Select Department --</asp:ListItem>
        <asp:ListItem Value="Research & Development">Research & Development</asp:ListItem>
   <asp:ListItem Value="Quality Control">Quality Control</asp:ListItem>
 <asp:ListItem Value="Human Resources">Human Resources</asp:ListItem>
         <asp:ListItem Value="Finance">Finance</asp:ListItem>
    <asp:ListItem Value="Marketing">Marketing</asp:ListItem>
 <asp:ListItem Value="IT Support">IT Support</asp:ListItem>
 <asp:ListItem Value="Operations">Operations</asp:ListItem>
   <asp:ListItem Value="Sales">Sales</asp:ListItem>
     <asp:ListItem Value="Legal">Legal</asp:ListItem>
<asp:ListItem Value="Customer Service">Customer Service</asp:ListItem>
        </asp:DropDownList>
      </div>
                
   <div class="form-group">
          <label for="ddlRoleClient">Role (Job Title) *</label>
           <select id="ddlRoleClient" class="form-control" onchange="updateRoleHiddenField();">
      <option value="">-- Select Department First --</option>
      </select>
   <asp:HiddenField ID="hdnSelectedRole" runat="server" />
   </div>
 
    <div class="form-group">
   <label for="<%= ddlHowDidYouHearUs.ClientID %>">How did you hear us? *</label>
      <asp:DropDownList ID="ddlHowDidYouHearUs" runat="server" CssClass="form-control" onchange="toggleReferralName();">
    <asp:ListItem Value="">-- Select --</asp:ListItem>
    <asp:ListItem Value="Job Caravan">Job Caravan</asp:ListItem>
    <asp:ListItem Value="Social Media">Social Media</asp:ListItem>
       <asp:ListItem Value="Referral">Referral</asp:ListItem>
  </asp:DropDownList>
             </div>
       
        <div id="referralNameSection" style="display: none;">
       <div class="form-group">
      <label for="<%= txtReferralName.ClientID %>">Referral Name</label>
   <asp:TextBox ID="txtReferralName" runat="server" CssClass="form-control" placeholder="Who referred you?"></asp:TextBox>
  </div>
          </div>

    <div class="form-group">
   <label>Contract Type</label>
        <asp:RadioButtonList ID="rblContractType" runat="server" CssClass="contract-type-radio" RepeatDirection="Horizontal">
              <asp:ListItem Value="Regular" Selected="True">Regular</asp:ListItem>
    <asp:ListItem Value="Contractual">Contractual</asp:ListItem>
     </asp:RadioButtonList>
    </div>

    <div class="form-group">
        <label>Hire As</label>
        <asp:RadioButtonList ID="rblHiringType" runat="server" CssClass="contract-type-radio" RepeatDirection="Horizontal">
            <asp:ListItem Value="Employee" Selected="True">Employee</asp:ListItem>
            <asp:ListItem Value="Manager">Manager</asp:ListItem>
        </asp:RadioButtonList>
        <span style="display:block;font-size:12px;color:#7F8C8D;margin-top:6px;">
            Selecting Manager will automatically create a manager login once hired.
        </span>
    </div>

   <div class="form-actions" style="margin-top: 30px;">
      <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-secondary" OnClientClick="closeModal(); return false;" />
 <asp:Button ID="btnAddApplicant" runat="server" Text="Submit Application" CssClass="btn btn-primary" OnClick="btnAddApplicant_Click" OnClientClick="return validateAddApplicantForm();" />
       </div>
    </div>
   </div>
    </div>

    <!-- View Details Modal -->
    <div id="viewDetailsModal" class="modal">
        <div class="modal-content" style="max-width: 700px;">
            <div class="modal-header">
       <h2 class="modal-title">Applicant Details</h2>
       <span class="close" onclick="closeDetailsModal()">&times;</span>
            </div>
     <div id="applicantDetailsContent" runat="server" style="max-height: 80vh; overflow-y: auto; padding: 40px;">
     <!-- Content will be populated by server-side code -->
  </div>
        </div>
  </div>

    <!-- Schedule Interview Modal -->
 <div id="scheduleInterviewModal" class="modal">
        <div class="modal-content" style="max-width: 600px;">
    <div class="modal-header">
           <h2 class="modal-title">Schedule Interview</h2>
          <span class="close" onclick="closeScheduleInterviewModal()">&times;</span>
      </div>
    <div id="scheduleMessageDiv" class="message" runat="server"></div>
            <div style="padding: 40px; max-height: 70vh; overflow-y: auto;">
    <div style="margin-bottom: 20px; padding: 15px; background-color: #f5f5f5; border-radius: 6px;">
     <strong>Selected Applicants:</strong>
         <ul id="selectedApplicantsList" style="margin: 10px 0 0 20px; padding: 0;"></ul>
          </div>

    <div class="form-group">
       <label for="<%= txtInterviewDate.ClientID %>">Interview Date *</label>
        <asp:TextBox ID="txtInterviewDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
      </div>
     <div class="form-group">
          <label for="<%= txtInterviewTime.ClientID %>">Interview Time *</label>
          <asp:TextBox ID="txtInterviewTime" runat="server" CssClass="form-control" TextMode="Time"></asp:TextBox>
  </div>
        <div class="form-group">
           <label for="<%= txtInterviewLocation.ClientID %>">Interview Location *</label>
  <asp:TextBox ID="txtInterviewLocation" runat="server" CssClass="form-control" placeholder="e.g., Conference Room A, Online, etc."></asp:TextBox>
 </div>
       <div class="form-group">
       <label for="<%= txtInterviewerName.ClientID %>">Interviewer Name *</label>
     <asp:TextBox ID="txtInterviewerName" runat="server" CssClass="form-control"></asp:TextBox>
           </div>
      <div class="form-group">
    <label for="<%= txtInterviewNotes.ClientID %>">Interview Notes</label>
        <asp:TextBox ID="txtInterviewNotes" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" placeholder="Additional notes or instructions for the interview..."></asp:TextBox>
        </div>

      <div class="form-actions" style="margin-top: 24px;">
                    <asp:Button ID="btnCancelSchedule" runat="server" Text="Cancel" CssClass="btn btn-secondary" OnClientClick="closeScheduleInterviewModal(); return false;" />
           <asp:Button ID="btnScheduleInterview" runat="server" Text="Schedule Interview" CssClass="btn btn-primary" OnClick="btnScheduleInterview_Click" OnClientClick="return validateScheduleInterviewForm();" />
                </div>
            </div>
    </div>
    </div>

    <!-- Hidden buttons for postback -->
 <asp:Button ID="btnViewDetails" runat="server" Style="display: none;" OnClick="btnViewDetails_Click" />
    <asp:Button ID="btnHireApplicant" runat="server" Style="display: none;" OnClick="btnHireApplicant_Click" />
    <asp:Button ID="btnNotHireApplicant" runat="server" Style="display: none;" OnClick="btnNotHireApplicant_Click" />
 <asp:Button ID="btnApproveApplicant" runat="server" Style="display: none;" OnClick="btnApproveApplicant_Click" />
    <asp:Button ID="btnDeclineApplicant" runat="server" Style="display: none;" OnClick="btnDeclineApplicant_Click" />
    <asp:HiddenField ID="hdnApplicantId" runat="server" />
    <asp:HiddenField ID="hdnSelectedApplicantIds" runat="server" />
</asp:Content>