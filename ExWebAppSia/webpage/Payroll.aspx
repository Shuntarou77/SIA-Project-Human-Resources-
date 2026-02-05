<%@ Page Title="Payroll Management" Language="C#" MasterPageFile="~/webpage/HR.Master" AutoEventWireup="true"
    CodeBehind="Payroll.aspx.cs" Inherits="ExWebAppSia.webpage.WebForm6" Async="true" Culture="en-US" UICulture="en-US"
    %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <meta charset="UTF-8" />
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <!-- jQuery -->
        <script src="https://code.jquery.com/jquery-3.6.0.min.js?v=20251128"></script>

        <!-- Payroll Configuration Handlers -->
        <script src="scripts/payroll-integration.js?v=20250129"></script>

        <!-- Payroll Employee Loading Handlers (NEW) -->
        <script src="scripts/payroll-employees.js?v=20250129"></script>

        <!-- Payroll Generation Handler (Generate Payroll button) -->
        <script src="scripts/generatePayroll-fixed.js?v=20250201"></script>

        <!-- Payroll Submission Handler (Step 4 & 5) -->
        <script src="scripts/payroll-submission.js?v=20250202"></script>

        <!-- Tab Navigation Function - Must be in head for immediate availability -->
        <script>
            // ========== TAB NAVIGATION FUNCTION (GLOBAL SCOPE) ==========
            // This function must be available immediately when page loads
            function switchTab(tabName) {
                console.log('[switchTab] Starting tab switch to:', tabName);

                // Validate input
                if (!tabName || typeof tabName !== 'string') {
                    console.error('[switchTab] Invalid tabName:', tabName);
                    return false;
                }

                try {
                    // Step 1: Hide all tab contents
                    var allTabs = document.querySelectorAll('.tab-content');
                    console.log('[switchTab] Found', allTabs.length, 'tab content elements');

                    for (var i = 0; i < allTabs.length; i++) {
                        allTabs[i].classList.remove('active');
                        allTabs[i].style.display = 'none'; // Force hide as backup
                    }

                    // Hide history simple container if switching away from history tab
                    if (tabName !== 'history') {
                        var historyContainer = document.getElementById('historySimpleContainer');
                        if (historyContainer) {
                            historyContainer.style.display = 'none';
                            console.log('[switchTab] History container hidden');
                        }
                    }

                    // Step 2: Remove active class from all buttons
                    var allButtons = document.querySelectorAll('.tab-btn');
                    console.log('[switchTab] Found', allButtons.length, 'tab buttons');

                    for (var j = 0; j < allButtons.length; j++) {
                        allButtons[j].classList.remove('active');
                    }

                    // Step 3: Show selected tab content
                    var targetTab = document.getElementById(tabName);
                    if (!targetTab) {
                        console.error('[switchTab] Tab element not found with id:', tabName);
                        console.log('[switchTab] Available tab IDs:',
                            Array.from(document.querySelectorAll('.tab-content')).map(function (el) { return el.id; })
                        );
                        return false;
                    }

                    // Add active class and show the tab
                    targetTab.classList.add('active');
                    targetTab.style.display = 'block'; // Force show as backup
                    console.log('[switchTab] Tab content shown:', tabName);

                    // Step 4: Activate corresponding button
                    var btnSelector = '.tab-btn[data-tab="' + tabName + '"]';
                    var activeButton = document.querySelector(btnSelector);

                    if (activeButton) {
                        activeButton.classList.add('active');
                        console.log('[switchTab] Button activated for:', tabName);
                    } else {
                        console.warn('[switchTab] Button not found with selector:', btnSelector);
                        // Try to find button by onclick attribute as fallback
                        var buttons = document.querySelectorAll('.tab-btn');
                        for (var k = 0; k < buttons.length; k++) {
                            if (buttons[k].getAttribute('onclick') && buttons[k].getAttribute('onclick').indexOf("'" + tabName + "'") !== -1) {
                                buttons[k].classList.add('active');
                                console.log('[switchTab] Button activated via fallback method');
                                break;
                            }
                        }
                    }

                    // Step 5: Load data for specific tabs
                    if (tabName === 'configuration') {
                        console.log('[switchTab] Configuration tab - loading data...');
                        // Hide history container when switching to other tabs
                        var historyContainer = document.getElementById('historySimpleContainer');
                        if (historyContainer) {
                            historyContainer.style.display = 'none';
                            console.log('[switchTab] History container hidden');
                        }

                        // Ensure configuration functions are available
                        if (typeof openConfigModal === 'undefined') {
                            console.warn('[switchTab] openConfigModal function not found - script may not be loaded');
                        } else {
                            console.log('[switchTab] openConfigModal function is available');
                        }

                        setTimeout(function () {
                            if (typeof loadPayrollConfigurations === 'function') {
                                console.log('[switchTab] Calling loadPayrollConfigurations()...');
                                loadPayrollConfigurations();
                            } else {
                                console.warn('[switchTab] loadPayrollConfigurations function not found');
                            }
                        }, 100);
                    } else if (tabName === 'payslips') {
                        console.log('[switchTab] Payslips tab activated');
                        // Hide history container when switching to other tabs
                        var historyContainer = document.getElementById('historySimpleContainer');
                        if (historyContainer) {
                            historyContainer.style.display = 'none';
                            console.log('[switchTab] History container hidden');
                        }
                        // Show payslips container if it exists
                        var payslipsContainer = document.getElementById('payslipsSimpleContainer');
                        if (payslipsContainer) {
                            payslipsContainer.style.display = 'block';
                            console.log('[switchTab] Payslips container shown');
                        }
                        // Load payslips data
                        setTimeout(function () {
                            console.log('[switchTab] Checking for loadPayslips function...');
                            console.log('[switchTab] typeof loadPayslips:', typeof loadPayslips);
                            console.log('[switchTab] typeof window.loadPayslips:', typeof window.loadPayslips);

                            if (typeof window.loadPayslips === 'function') {
                                console.log('[switchTab] Calling window.loadPayslips()...');
                                window.loadPayslips();
                            } else if (typeof loadPayslips === 'function') {
                                console.log('[switchTab] Calling loadPayslips()...');
                                loadPayslips();
                            } else {
                                console.warn('[switchTab] loadPayslips function not found');
                                console.warn('[switchTab] Available functions:', Object.keys(window).filter(k => k.includes('Payslip') || k.includes('load')));
                            }
                        }, 100);
                    } else if (tabName === 'history') {
                        console.log('[switchTab] History tab activated - loading history...');
                        // Hide payslips container when switching to history
                        var payslipsContainer = document.getElementById('payslipsSimpleContainer');
                        if (payslipsContainer) {
                            payslipsContainer.style.display = 'none';
                            console.log('[switchTab] Payslips container hidden');
                        }
                        // Show history container if it exists
                        var historyContainer = document.getElementById('historySimpleContainer');
                        if (historyContainer) {
                            historyContainer.style.display = 'block';
                            console.log('[switchTab] History container shown');
                        }
                        setTimeout(function () {
                            if (typeof loadPayrollHistory === 'function') {
                                console.log('[switchTab] Calling loadPayrollHistory()...');
                                loadPayrollHistory();
                            } else {
                                console.warn('[switchTab] loadPayrollHistory function not found');
                            }
                        }, 100);
                    } else if (tabName === 'payroll-gen') {
                        console.log('[switchTab] Payroll Generation tab activated');
                        // Hide history and payslips containers when switching to other tabs
                        var historyContainer = document.getElementById('historySimpleContainer');
                        if (historyContainer) {
                            historyContainer.style.display = 'none';
                            console.log('[switchTab] History container hidden');
                        }
                        var payslipsContainer = document.getElementById('payslipsSimpleContainer');
                        if (payslipsContainer) {
                            payslipsContainer.style.display = 'none';
                            console.log('[switchTab] Payslips container hidden');
                        }
                    } else {
                        // Hide history and payslips containers when switching to any other tab
                        var historyContainer = document.getElementById('historySimpleContainer');
                        if (historyContainer) {
                            historyContainer.style.display = 'none';
                            console.log('[switchTab] History container hidden');
                        }
                        var payslipsContainer = document.getElementById('payslipsSimpleContainer');
                        if (payslipsContainer) {
                            payslipsContainer.style.display = 'none';
                            console.log('[switchTab] Payslips container hidden');
                        }
                    }

                    // Step 6: Scroll to top
                    window.scrollTo({ top: 0, behavior: 'smooth' });

                    console.log('[switchTab] Tab switch completed successfully');
                    return true;

                } catch (error) {
                    console.error('[switchTab] ERROR:', error);
                    console.error('[switchTab] Error details:', {
                        message: error.message,
                        stack: error.stack,
                        tabName: tabName
                    });
                    return false;
                }
            }

            // Make sure function is in global scope (window object)
            window.switchTab = switchTab;

            /**
             * Handle Add New Configuration button click
             * This ensures the function is available regardless of tab order
             */
            function handleAddNewConfig() {
                console.log('[handleAddNewConfig] Button clicked');
                console.log('[handleAddNewConfig] Checking if openConfigModal exists:', typeof openConfigModal);
                console.log('[handleAddNewConfig] Checking if window.openConfigModal exists:', typeof window.openConfigModal);

                // Try multiple ways to call the function
                if (typeof window.openConfigModal === 'function') {
                    console.log('[handleAddNewConfig] Calling window.openConfigModal');
                    window.openConfigModal('create', null);
                } else if (typeof openConfigModal === 'function') {
                    console.log('[handleAddNewConfig] Calling openConfigModal');
                    openConfigModal('create', null);
                } else {
                    console.error('[handleAddNewConfig] openConfigModal function not found!');
                    alert('Configuration modal function not loaded. Please refresh the page.\n\nIf the problem persists, check the browser console for errors.');
                }
            }

            // Expose to global scope
            window.handleAddNewConfig = handleAddNewConfig;

            /**
             * View payroll history details
             * Defined in head so it's available when buttons call it
             */
            function viewPayrollHistory(payRunId) {
                console.log('[viewPayrollHistory] Viewing pay run:', payRunId);

                // Check if jQuery is available
                if (typeof $ === 'undefined') {
                    alert('jQuery is not loaded. Please refresh the page.');
                    return;
                }

                // Create a simple modal overlay
                var existingModal = document.getElementById('simplePayrollModal');
                if (existingModal) {
                    existingModal.remove();
                }

                // Create modal overlay
                var modalOverlay = document.createElement('div');
                modalOverlay.id = 'simplePayrollModal';
                modalOverlay.style.cssText = 'position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.7); z-index:99999; display:flex; justify-content:center; align-items:center;';

                // Create modal content
                var modalContent = document.createElement('div');
                modalContent.style.cssText = 'background:white; width:90%; max-width:1000px; max-height:90vh; border-radius:12px; padding:30px; position:relative; overflow-y:auto; box-shadow:0 10px 40px rgba(0,0,0,0.3);';
                modalContent.innerHTML = '<div style="text-align:center; padding:40px;"><div style="font-size:24px;">Loading...</div><p>Loading payroll details...</p></div>';

                modalOverlay.appendChild(modalContent);
                document.body.appendChild(modalOverlay);

                // Close on overlay click
                modalOverlay.addEventListener('click', function (e) {
                    if (e.target === modalOverlay) {
                        modalOverlay.remove();
                    }
                });

                // Fetch pay run details
                $.ajax({
                    type: 'GET',
                    url: '../Handler/GetPayRunDetailsHandler.ashx?id=' + encodeURIComponent(payRunId),
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    timeout: 30000,
                    success: function (response) {
                        console.log('[viewPayrollHistory] Response received:', response);

                        if (response && response.success && response.data) {
                            var data = response.data;
                            displaySimplePayrollDetails(data, modalContent);
                        } else {
                            var errorMsg = (response && response.message) ? response.message : 'Failed to load payroll details';
                            modalContent.innerHTML = '<div style="text-align:center; padding:40px; color:#991B1B;"><h2>Error</h2><p>' + errorMsg + '</p><button type="button" onclick="document.getElementById(\'simplePayrollModal\').remove()" style="margin-top:20px; padding:10px 20px; background:#A44F56; color:white; border:none; border-radius:8px; cursor:pointer;">Close</button></div>';
                        }
                    },
                    error: function (xhr, status, error) {
                        console.error('[viewPayrollHistory] AJAX Error:', error);
                        modalContent.innerHTML = '<div style="text-align:center; padding:40px; color:#991B1B;"><h2>Error</h2><p>Failed to load payroll details: ' + error + '</p><button type="button" onclick="document.getElementById(\'simplePayrollModal\').remove()" style="margin-top:20px; padding:10px 20px; background:#A44F56; color:white; border:none; border-radius:8px; cursor:pointer;">Close</button></div>';
                    }
                });
            }

            function displaySimplePayrollDetails(data, container) {
                var statusBg = '#E5E7EB';
                var statusColor = '#374151';
                switch (data.status) {
                    case 'Approved':
                        statusBg = '#D1FAE5';
                        statusColor = '#065F46';
                        break;
                    case 'Draft':
                        statusBg = '#FEF3C7';
                        statusColor = '#92400E';
                        break;
                    case 'Calculated':
                        statusBg = '#DBEAFE';
                        statusColor = '#1E40AF';
                        break;
                }

                var periodText = (data.payPeriodStart && data.payPeriodEnd) ? (data.payPeriodStart + ' - ' + data.payPeriodEnd) : (data.period || 'N/A');

                var html = '<button type="button" onclick="document.getElementById(\'simplePayrollModal\').remove()" style="position:absolute; top:15px; right:15px; font-size:28px; cursor:pointer; background:none; border:none; color:#666; width:40px; height:40px; line-height:40px; text-align:center;">&times;</button>';
                html += '<h2 style="margin-bottom:20px; color:#A44F56; padding-right:40px;">Payroll Run Details</h2>';

                // Summary Section
                html += '<div style="background:#F9FAFB; padding:20px; border-radius:8px; margin-bottom:20px;">';
                html += '<div style="display:grid; grid-template-columns:repeat(2, 1fr); gap:15px;">';
                html += '<div><strong>Pay Run Number:</strong><br/>' + (data.payRunNumber || 'N/A') + '</div>';
                html += '<div><strong>Period:</strong><br/>' + periodText + '</div>';
                html += '<div><strong>Pay Date:</strong><br/>' + (data.payDate || 'N/A') + '</div>';
                html += '<div><strong>Status:</strong><br/><span style="background:' + statusBg + ';color:' + statusColor + ';padding:4px 12px;border-radius:12px;font-size:12px;font-weight:600;">' + (data.status || 'N/A') + '</span></div>';
                html += '<div><strong>Total Employees:</strong><br/>' + (data.totalEmployees || 0) + '</div>';
                html += '<div><strong>Created By:</strong><br/>' + (data.createdBy || 'N/A') + '</div>';
                html += '</div></div>';

                // Totals Section
                html += '<div style="background:white; padding:20px; border-radius:8px; margin-bottom:20px; border:2px solid #F9D2D6;">';
                html += '<h3 style="margin-bottom:15px; color:#A44F56;">Summary Totals</h3>';
                html += '<div style="display:grid; grid-template-columns:repeat(3, 1fr); gap:15px;">';
                html += '<div><strong style="color:#666;">Total Gross Salary:</strong><br/><span style="color:#22C55E; font-size:20px; font-weight:700;">&#8369;' + (data.totalGrossSalary || 0).toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</span></div>';
                html += '<div><strong style="color:#666;">Total Deductions:</strong><br/><span style="color:#9CA3AF; font-size:20px; font-weight:700;">&#8369;' + (data.totalDeductions || 0).toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</span></div>';
                html += '<div><strong style="color:#666;">Total Net Salary:</strong><br/><span style="color:#A44F56; font-size:20px; font-weight:700;">&#8369;' + (data.totalNetSalary || 0).toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</span></div>';
                html += '</div></div>';

                // Employee Payslips Section - Detailed breakdown for each employee
                if (data.items && data.items.length > 0) {
                    html += '<div style="margin-bottom:20px;">';
                    html += '<h3 style="margin-bottom:20px; color:#A44F56; font-size:20px;">Employee Payslips</h3>';

                    data.items.forEach(function (item, index) {
                        // Payslip Card
                        html += '<div style="background:white; border:2px solid #F9D2D6; border-radius:12px; padding:30px; margin-bottom:30px; page-break-inside:avoid;">';

                        // Employee Header
                        html += '<div style="border-bottom:2px solid #F9D2D6; padding-bottom:20px; margin-bottom:20px;">';
                        html += '<h4 style="margin:0 0 10px 0; color:#A44F56; font-size:18px;">' + (item.employeeName || 'N/A') + '</h4>';
                        html += '<div style="display:grid; grid-template-columns:repeat(3, 1fr); gap:15px; color:#666; font-size:14px;">';
                        html += '<div><strong>Department:</strong> ' + (item.department || 'N/A') + '</div>';
                        html += '<div><strong>Position:</strong> ' + (item.position || 'N/A') + '</div>';
                        html += '<div><strong>Period:</strong> ' + periodText + '</div>';
                        html += '</div>';
                        html += '</div>';

                        // Earnings Section
                        html += '<div style="margin-bottom:20px;">';
                        html += '<h5 style="margin:0 0 15px 0; color:#059669; font-size:16px; font-weight:700;">EARNINGS</h5>';
                        html += '<table style="width:100%; border-collapse:collapse;">';

                        var basicSalary = parseFloat(item.basicSalary || 0);
                        var proratedBasic = parseFloat(item.proratedBasicSalary || 0);
                        var allowances = parseFloat(item.allowances || 0);
                        var overtimePay = parseFloat(item.overtimePay || 0);
                        var holidayPay = parseFloat(item.holidayPay || 0);
                        var nightDiffPay = parseFloat(item.nightDifferentialPay || 0);
                        var bonuses = parseFloat(item.bonuses || 0);
                        var otherEarnings = parseFloat(item.otherEarnings || 0);
                        var grossSalary = parseFloat(item.grossSalary || 0);

                        if (proratedBasic > 0) {
                            html += '<tr><td style="padding:8px 0; color:#666;">Basic Salary (Prorated)</td><td style="text-align:right; font-weight:600;">&#8369;' + proratedBasic.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td></tr>';
                        }
                        if (allowances > 0) {
                            html += '<tr><td style="padding:8px 0; color:#666;">Allowances</td><td style="text-align:right; font-weight:600;">&#8369;' + allowances.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td></tr>';
                        }
                        if (overtimePay > 0) {
                            html += '<tr><td style="padding:8px 0; color:#666;">Overtime Pay</td><td style="text-align:right; font-weight:600;">&#8369;' + overtimePay.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td></tr>';
                        }
                        if (holidayPay > 0) {
                            html += '<tr><td style="padding:8px 0; color:#666;">Holiday Pay</td><td style="text-align:right; font-weight:600;">&#8369;' + holidayPay.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td></tr>';
                        }
                        if (nightDiffPay > 0) {
                            html += '<tr><td style="padding:8px 0; color:#666;">Night Differential</td><td style="text-align:right; font-weight:600;">&#8369;' + nightDiffPay.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td></tr>';
                        }
                        if (bonuses > 0) {
                            html += '<tr><td style="padding:8px 0; color:#666;">Bonuses</td><td style="text-align:right; font-weight:600;">&#8369;' + bonuses.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td></tr>';
                        }
                        if (otherEarnings > 0) {
                            html += '<tr><td style="padding:8px 0; color:#666;">Other Earnings</td><td style="text-align:right; font-weight:600;">&#8369;' + otherEarnings.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td></tr>';
                        }

                        html += '<tr style="border-top:2px solid #E5E7EB; margin-top:10px;"><td style="padding:12px 0; font-weight:700; color:#059669;">Total Gross Salary</td><td style="text-align:right; font-weight:700; font-size:18px; color:#059669;">&#8369;' + grossSalary.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td></tr>';
                        html += '</table>';
                        html += '</div>';

                        // Deductions Section
                        html += '<div style="margin-bottom:20px;">';
                        html += '<h5 style="margin:0 0 15px 0; color:#DC2626; font-size:16px; font-weight:700;">DEDUCTIONS</h5>';
                        html += '<table style="width:100%; border-collapse:collapse;">';

                        // Statutory Deductions
                        var sssDed = parseFloat(item.sssDeduction || 0);
                        var philHealthDed = parseFloat(item.philHealthDeduction || 0);
                        var pagIbigDed = parseFloat(item.pagIbigDeduction || 0);
                        var withholdingTax = parseFloat(item.withholdingTax || 0);

                        if (sssDed > 0 || philHealthDed > 0 || pagIbigDed > 0 || withholdingTax > 0) {
                            html += '<tr><td colspan="2" style="padding:8px 0; font-weight:600; color:#666;">Statutory Deductions</td></tr>';
                            if (sssDed > 0) {
                                html += '<tr><td style="padding:8px 0 8px 20px; color:#666;">SSS</td><td style="text-align:right; font-weight:600;">&#8369;' + sssDed.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td></tr>';
                            }
                            if (philHealthDed > 0) {
                                html += '<tr><td style="padding:8px 0 8px 20px; color:#666;">PhilHealth</td><td style="text-align:right; font-weight:600;">&#8369;' + philHealthDed.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td></tr>';
                            }
                            if (pagIbigDed > 0) {
                                html += '<tr><td style="padding:8px 0 8px 20px; color:#666;">Pag-IBIG</td><td style="text-align:right; font-weight:600;">&#8369;' + pagIbigDed.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td></tr>';
                            }
                            if (withholdingTax > 0) {
                                html += '<tr><td style="padding:8px 0 8px 20px; color:#666;">Withholding Tax</td><td style="text-align:right; font-weight:600;">&#8369;' + withholdingTax.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td></tr>';
                            }
                        }

                        // Loan Deductions
                        var sssLoan = parseFloat(item.sssLoan || 0);
                        var pagIbigLoan = parseFloat(item.pagIbigLoan || 0);
                        var companyLoan = parseFloat(item.companyLoan || 0);

                        if (sssLoan > 0 || pagIbigLoan > 0 || companyLoan > 0) {
                            html += '<tr><td colspan="2" style="padding:8px 0; font-weight:600; color:#666; margin-top:10px;">Loan Deductions</td></tr>';
                            if (sssLoan > 0) {
                                html += '<tr><td style="padding:8px 0 8px 20px; color:#666;">SSS Loan</td><td style="text-align:right; font-weight:600;">&#8369;' + sssLoan.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td></tr>';
                            }
                            if (pagIbigLoan > 0) {
                                html += '<tr><td style="padding:8px 0 8px 20px; color:#666;">Pag-IBIG Loan</td><td style="text-align:right; font-weight:600;">&#8369;' + pagIbigLoan.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td></tr>';
                            }
                            if (companyLoan > 0) {
                                html += '<tr><td style="padding:8px 0 8px 20px; color:#666;">Company Loan</td><td style="text-align:right; font-weight:600;">&#8369;' + companyLoan.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td></tr>';
                            }
                        }

                        // Penalty Deductions
                        var absencePenalty = parseFloat(item.absencePenalty || 0);
                        var latePenalty = parseFloat(item.latePenalty || 0);
                        var unpaidLeaveDed = parseFloat(item.unpaidLeaveDeduction || 0);
                        var otherDed = parseFloat(item.otherDeductions || 0);

                        if (absencePenalty > 0 || latePenalty > 0 || unpaidLeaveDed > 0 || otherDed > 0) {
                            html += '<tr><td colspan="2" style="padding:8px 0; font-weight:600; color:#666; margin-top:10px;">Penalty & Other Deductions</td></tr>';
                            if (absencePenalty > 0) {
                                html += '<tr><td style="padding:8px 0 8px 20px; color:#666;">Absence Penalty</td><td style="text-align:right; font-weight:600;">&#8369;' + absencePenalty.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td></tr>';
                            }
                            if (latePenalty > 0) {
                                html += '<tr><td style="padding:8px 0 8px 20px; color:#666;">Late Penalty</td><td style="text-align:right; font-weight:600;">&#8369;' + latePenalty.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td></tr>';
                            }
                            if (unpaidLeaveDed > 0) {
                                html += '<tr><td style="padding:8px 0 8px 20px; color:#666;">Unpaid Leave</td><td style="text-align:right; font-weight:600;">&#8369;' + unpaidLeaveDed.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td></tr>';
                            }
                            if (otherDed > 0) {
                                html += '<tr><td style="padding:8px 0 8px 20px; color:#666;">Other Deductions</td><td style="text-align:right; font-weight:600;">&#8369;' + otherDed.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td></tr>';
                            }
                        }

                        var totalDeductions = parseFloat(item.totalDeductions || 0);
                        html += '<tr style="border-top:2px solid #E5E7EB; margin-top:10px;"><td style="padding:12px 0; font-weight:700; color:#DC2626;">Total Deductions</td><td style="text-align:right; font-weight:700; font-size:18px; color:#DC2626;">&#8369;' + totalDeductions.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td></tr>';
                        html += '</table>';
                        html += '</div>';

                        // Net Salary
                        var netSalary = parseFloat(item.netSalary || 0);
                        html += '<div style="background:linear-gradient(135deg, #2563EB 0%, #1E40AF 100%); color:white; padding:20px; border-radius:8px; text-align:center; margin-top:20px;">';
                        html += '<div style="font-size:14px; margin-bottom:5px; opacity:0.9;">NET SALARY</div>';
                        html += '<div style="font-size:32px; font-weight:700;">&#8369;' + netSalary.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</div>';
                        html += '</div>';

                        // Attendance Summary (if available)
                        if (item.daysPresent !== undefined || item.daysAbsent !== undefined || item.daysLate !== undefined) {
                            html += '<div style="margin-top:20px; padding:15px; background:#F9FAFB; border-radius:8px; font-size:14px; color:#666;">';
                            html += '<strong>Attendance Summary:</strong> ';
                            var attendanceParts = [];
                            if (item.daysPresent !== undefined) attendanceParts.push('Present: ' + item.daysPresent);
                            if (item.daysAbsent !== undefined) attendanceParts.push('Absent: ' + item.daysAbsent);
                            if (item.daysLate !== undefined) attendanceParts.push('Late: ' + item.daysLate);
                            html += attendanceParts.join(' | ');
                            html += '</div>';
                        }

                        html += '</div>'; // End payslip card
                    });

                    html += '</div>';
                } else {
                    html += '<div style="padding:40px; text-align:center; color:#666;">No employee records found</div>';
                }

                container.innerHTML = html;
            }

            /**
             * Display payroll details in modal
             */
            function displayPayrollDetails(data) {
                console.log('[displayPayrollDetails] Starting to display data:', data);
                var modal = document.getElementById('payrollDetailsModal');
                var modalContent = document.getElementById('payrollDetailsContent');

                if (!modal) {
                    console.error('[displayPayrollDetails] Modal element not found!');
                    return;
                }

                if (!modalContent) {
                    console.error('[displayPayrollDetails] Modal content element not found!');
                    return;
                }

                // Ensure modal is visible
                modal.style.setProperty('display', 'flex', 'important');
                modal.style.setProperty('visibility', 'visible', 'important');
                modal.style.setProperty('opacity', '1', 'important');
                modal.style.setProperty('z-index', '2000', 'important');
                console.log('[displayPayrollDetails] Modal display set to flex');

                var statusBg = '#E5E7EB';
                var statusColor = '#374151';
                switch (data.status) {
                    case 'Approved':
                        statusBg = '#D1FAE5';
                        statusColor = '#065F46';
                        break;
                    case 'Draft':
                        statusBg = '#FEF3C7';
                        statusColor = '#92400E';
                        break;
                    case 'Calculated':
                        statusBg = '#DBEAFE';
                        statusColor = '#1E40AF';
                        break;
                }

                var html = '<div style="max-height:80vh; overflow-y:auto;">';
                html += '<h2 style="margin-bottom:20px; color:#A44F56;">Payroll Run Details</h2>';

                // Summary Section
                html += '<div style="background:#F9FAFB; padding:20px; border-radius:12px; margin-bottom:20px;">';
                html += '<div style="display:grid; grid-template-columns:repeat(2, 1fr); gap:15px;">';
                html += '<div><strong>Pay Run Number:</strong><br/>' + (data.payRunNumber || 'N/A') + '</div>';
                var periodText = (data.payPeriodStart && data.payPeriodEnd) ? (data.payPeriodStart + ' - ' + data.payPeriodEnd) : (data.period || 'N/A');
                html += '<div><strong>Period:</strong><br/>' + periodText + '</div>';
                html += '<div><strong>Pay Date:</strong><br/>' + (data.payDate || 'N/A') + '</div>';
                html += '<div><strong>Status:</strong><br/><span style="background:' + statusBg + ';color:' + statusColor + ';padding:4px 12px;border-radius:12px;font-size:12px;font-weight:600;">' + (data.status || 'N/A') + '</span></div>';
                html += '<div><strong>Total Employees:</strong><br/>' + (data.totalEmployees || 0) + '</div>';
                html += '<div><strong>Created By:</strong><br/>' + (data.createdBy || 'N/A') + '</div>';
                html += '</div></div>';

                // Totals Section
                html += '<div style="background:white; padding:20px; border-radius:12px; margin-bottom:20px; border:2px solid #F9D2D6;">';
                html += '<h3 style="margin-bottom:15px; color:#A44F56;">Summary Totals</h3>';
                html += '<div style="display:grid; grid-template-columns:repeat(3, 1fr); gap:15px;">';
                html += '<div><strong style="color:#666;">Total Gross Salary:</strong><br/><span style="color:#22C55E; font-size:20px; font-weight:700;">&#8369;' + (data.totalGrossSalary || 0).toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</span></div>';
                html += '<div><strong style="color:#666;">Total Deductions:</strong><br/><span style="color:#9CA3AF; font-size:20px; font-weight:700;">&#8369;' + (data.totalDeductions || 0).toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</span></div>';
                html += '<div><strong style="color:#666;">Total Net Salary:</strong><br/><span style="color:#A44F56; font-size:20px; font-weight:700;">&#8369;' + (data.totalNetSalary || 0).toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</span></div>';
                html += '</div></div>';

                // Employee Items Table
                html += '<h3 style="margin-bottom:15px; color:#A44F56;">Employee Breakdown</h3>';
                html += '<div style="overflow-x:auto;">';
                html += '<table style="width:100%; border-collapse:collapse; background:white; border-radius:12px; overflow:hidden;">';
                html += '<thead><tr style="background:linear-gradient(135deg, #A44F56 0%, #8B3E45 100%); color:white;">';
                html += '<th style="padding:12px; text-align:left; font-weight:700; font-size:12px; text-transform:uppercase;">Employee</th>';
                html += '<th style="padding:12px; text-align:left; font-weight:700; font-size:12px; text-transform:uppercase;">Department</th>';
                html += '<th style="padding:12px; text-align:right; font-weight:700; font-size:12px; text-transform:uppercase;">Gross</th>';
                html += '<th style="padding:12px; text-align:right; font-weight:700; font-size:12px; text-transform:uppercase;">Deductions</th>';
                html += '<th style="padding:12px; text-align:right; font-weight:700; font-size:12px; text-transform:uppercase;">Net</th>';
                html += '</tr></thead><tbody>';

                if (data.items && data.items.length > 0) {
                    data.items.forEach(function (item) {
                        html += '<tr style="border-bottom:1px solid #F9D2D6;">';
                        html += '<td style="padding:12px;"><strong>' + (item.employeeName || 'N/A') + '</strong><br/><small style="color:#666;">' + (item.employeeId || '') + '</small></td>';
                        html += '<td style="padding:12px;">' + (item.department || 'N/A') + '</td>';
                        html += '<td style="padding:12px; text-align:right; color:#22C55E; font-weight:600;">&#8369;' + (item.grossSalary || 0).toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td>';
                        html += '<td style="padding:12px; text-align:right; color:#9CA3AF;">&#8369;' + (item.totalDeductions || 0).toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td>';
                        html += '<td style="padding:12px; text-align:right; color:#A44F56; font-weight:700;">&#8369;' + (item.netSalary || 0).toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td>';
                        html += '</tr>';
                    });
                } else {
                    html += '<tr><td colspan="5" style="padding:20px; text-align:center; color:#666;">No employee records found</td></tr>';
                }

                html += '</tbody></table></div>';
                html += '</div>';

                modalContent.innerHTML = html;

                // Final check - ensure modal is visible
                if (modal) {
                    modal.style.setProperty('display', 'flex', 'important');
                    modal.style.setProperty('visibility', 'visible', 'important');
                    modal.style.setProperty('opacity', '1', 'important');
                    console.log('[displayPayrollDetails] Content set, modal should be visible');
                    console.log('[displayPayrollDetails] Modal computed display:', window.getComputedStyle(modal).display);
                    console.log('[displayPayrollDetails] Modal computed visibility:', window.getComputedStyle(modal).visibility);
                    console.log('[displayPayrollDetails] Modal computed z-index:', window.getComputedStyle(modal).zIndex);
                }
            }

            /**
             * Close payroll details modal
             */
            function closePayrollDetailsModal() {
                var modal = document.getElementById('payrollDetailsModal');
                if (modal) {
                    modal.style.display = 'none';
                }
            }

            // Expose functions to global scope
            window.viewPayrollHistory = viewPayrollHistory;
            window.closePayrollDetailsModal = closePayrollDetailsModal;
            window.displayPayrollDetails = displayPayrollDetails;
            window.displaySimplePayrollDetails = displaySimplePayrollDetails;

            /**
             * Load Payslips - Shows approved payroll runs
             * Fetches approved payrolls from PayRun collection and displays them
             * Defined in head so it's available when switchTab calls it
             */
            function loadPayslips() {
                console.log('[loadPayslips] Starting to load approved payrolls...');

                var loadingState = document.getElementById('payslipsLoadingState');
                var errorState = document.getElementById('payslipsErrorState');
                var emptyState = document.getElementById('payslipsEmptyState');
                var tableContainer = document.getElementById('payslipsTableContainer');
                var tableBody = document.getElementById('payslipsTableBody');

                if (!loadingState || !errorState || !emptyState || !tableContainer || !tableBody) {
                    console.warn('[loadPayslips] Some elements not found, waiting for DOM...');
                    setTimeout(function () {
                        loadPayslips();
                    }, 200);
                    return;
                }

                if (loadingState) loadingState.style.display = 'block';
                if (errorState) errorState.style.display = 'none';
                if (emptyState) emptyState.style.display = 'none';
                if (tableContainer) tableContainer.style.display = 'none';

                if (typeof $ === 'undefined') {
                    console.error('[loadPayslips] jQuery is not loaded!');
                    if (loadingState) loadingState.style.display = 'none';
                    if (errorState) {
                        errorState.style.display = 'block';
                        var errorMessageEl = document.getElementById('payslipsErrorMessage');
                        if (errorMessageEl) {
                            errorMessageEl.textContent = 'jQuery is not loaded. Please refresh the page.';
                        }
                    }
                    return;
                }

                // Fetch approved payrolls from PayRun collection
                $.ajax({
                    type: 'GET',
                    url: '/Handler/GetPayrollHistoryHandler.ashx',
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    timeout: 30000,
                    success: function (response) {
                        console.log('[loadPayslips] Response received:', response);

                        if (loadingState) loadingState.style.display = 'none';

                        if (response && response.success && response.data) {
                            // Filter only approved payrolls
                            var approvedPayrolls = (response.data || []).filter(function (pr) {
                                return pr.status === 'Approved';
                            });

                            console.log('[loadPayslips] Found', approvedPayrolls.length, 'approved payrolls');

                            if (approvedPayrolls.length === 0) {
                                if (emptyState) emptyState.style.display = 'block';
                                if (tableContainer) tableContainer.style.display = 'none';
                            } else {
                                // SIMPLE SOLUTION: Create a new visible container and populate it with the table (same as history tab)
                                console.log('[loadPayslips] Creating simple visible table container...');

                                // Find or create a visible container after the tab navigation
                                var tabNavigation = document.querySelector('.tab-navigation');
                                var simpleContainer = document.getElementById('payslipsSimpleContainer');

                                if (!simpleContainer && tabNavigation) {
                                    // Create a new simple container right after tab navigation
                                    simpleContainer = document.createElement('div');
                                    simpleContainer.id = 'payslipsSimpleContainer';
                                    simpleContainer.style.cssText = 'display:block !important; width:100% !important; padding:40px; background:white; border-radius:20px; margin-top:20px; box-shadow:0 4px 6px rgba(0,0,0,0.1);';

                                    // Insert after tab navigation
                                    if (tabNavigation.nextSibling) {
                                        tabNavigation.parentElement.insertBefore(simpleContainer, tabNavigation.nextSibling);
                                    } else {
                                        tabNavigation.parentElement.appendChild(simpleContainer);
                                    }
                                    console.log('[loadPayslips] Created simple container');
                                }

                                if (simpleContainer && approvedPayrolls && approvedPayrolls.length > 0) {
                                    // Clear and create table structure in simple container
                                    simpleContainer.innerHTML = '<h2 style="margin-bottom:30px; color:#A44F56; font-size:28px; font-weight:700;">Approved Payrolls</h2>';

                                    // Create table
                                    var simpleTable = document.createElement('table');
                                    simpleTable.style.cssText = 'width:100%; border-collapse:collapse; background:white;';

                                    // Create header
                                    var thead = document.createElement('thead');
                                    var headerRow = document.createElement('tr');
                                    headerRow.style.cssText = 'background:linear-gradient(135deg, #A44F56 0%, #8B3E45 100%); color:white;';

                                    var headers = ['Pay Run', 'Period', 'Employees', 'Gross', 'Deductions', 'Net', 'Pay Date', 'Actions'];
                                    headers.forEach(function (header) {
                                        var th = document.createElement('th');
                                        th.textContent = header;
                                        th.style.cssText = 'padding:16px; font-weight:700; text-transform:uppercase; font-size:12px; text-align:left;';
                                        headerRow.appendChild(th);
                                    });

                                    thead.appendChild(headerRow);

                                    // Create body
                                    var tbody = document.createElement('tbody');

                                    approvedPayrolls.forEach(function (payroll) {
                                        var row = document.createElement('tr');
                                        row.style.cssText = 'border-bottom:1px solid #E5E7EB;';

                                        var grossAmount = parseFloat(payroll.totalGrossSalary || 0);
                                        var deductionsAmount = parseFloat(payroll.totalDeductions || 0);
                                        var netAmount = parseFloat(payroll.totalNetSalary || 0);

                                        // Create cells
                                        var payRunCell = document.createElement('td');
                                        payRunCell.style.cssText = 'padding:16px; border-bottom:1px solid #E5E7EB;';
                                        payRunCell.innerHTML = '<strong>' + (payroll.payRunNumber || 'N/A') + '</strong><br/><small style="color:#666;">' + (payroll.description || '') + '</small>';

                                        var periodCell = document.createElement('td');
                                        periodCell.style.cssText = 'padding:16px; border-bottom:1px solid #E5E7EB;';
                                        periodCell.textContent = payroll.period || 'N/A';

                                        var employeesCell = document.createElement('td');
                                        employeesCell.style.cssText = 'padding:16px; border-bottom:1px solid #E5E7EB; text-align:center;';
                                        employeesCell.textContent = payroll.totalEmployees || 0;

                                        var grossCell = document.createElement('td');
                                        grossCell.style.cssText = 'padding:16px; border-bottom:1px solid #E5E7EB; text-align:right; color:#059669; font-weight:600;';
                                        grossCell.innerHTML = '&#8369;' + grossAmount.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

                                        var deductionsCell = document.createElement('td');
                                        deductionsCell.style.cssText = 'padding:16px; border-bottom:1px solid #E5E7EB; text-align:right; color:#6B7280; font-weight:600;';
                                        deductionsCell.innerHTML = '&#8369;' + deductionsAmount.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

                                        var netCell = document.createElement('td');
                                        netCell.style.cssText = 'padding:16px; border-bottom:1px solid #E5E7EB; text-align:right; color:#2563EB; font-weight:700;';
                                        netCell.innerHTML = '&#8369;' + netAmount.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

                                        var payDateCell = document.createElement('td');
                                        payDateCell.style.cssText = 'padding:16px; border-bottom:1px solid #E5E7EB;';
                                        payDateCell.textContent = payroll.payDate || 'N/A';

                                        var actionsCell = document.createElement('td');
                                        actionsCell.style.cssText = 'padding:16px; border-bottom:1px solid #E5E7EB;';
                                        var viewButton = document.createElement('button');
                                        viewButton.type = 'button';
                                        viewButton.style.cssText = 'padding:8px 16px;background:#F3F4F6;border:none;border-radius:6px;cursor:pointer;margin-right:8px;';
                                        viewButton.textContent = 'View';
                                        viewButton.addEventListener('click', function () {
                                            if (typeof window.viewPayrollHistory === 'function') {
                                                window.viewPayrollHistory(payroll.id);
                                            } else {
                                                console.error('[loadPayslips] viewPayrollHistory function not found!');
                                                alert('View function not available. Please refresh the page.');
                                            }
                                        });
                                        actionsCell.appendChild(viewButton);

                                        row.appendChild(payRunCell);
                                        row.appendChild(periodCell);
                                        row.appendChild(employeesCell);
                                        row.appendChild(grossCell);
                                        row.appendChild(deductionsCell);
                                        row.appendChild(netCell);
                                        row.appendChild(payDateCell);
                                        row.appendChild(actionsCell);

                                        tbody.appendChild(row);
                                    });

                                    simpleTable.appendChild(thead);
                                    simpleTable.appendChild(tbody);
                                    simpleContainer.appendChild(simpleTable);

                                    // Show the simple container
                                    simpleContainer.style.setProperty('display', 'block', 'important');
                                    simpleContainer.style.setProperty('visibility', 'visible', 'important');

                                    console.log('[loadPayslips] Simple table created and populated with', approvedPayrolls.length, 'approved payrolls');
                                } else {
                                    console.error('[loadPayslips] Could not create simple container or no data!');
                                }
                            }
                        } else {
                            var errorMsg = (response && response.message) ? response.message : 'Failed to load approved payrolls';
                            if (errorState) {
                                errorState.style.display = 'block';
                                var errorMessageEl = document.getElementById('payslipsErrorMessage');
                                if (errorMessageEl) {
                                    errorMessageEl.textContent = errorMsg;
                                }
                            }
                        }
                    },
                    error: function (xhr, status, error) {
                        console.error('[loadPayslips] AJAX Error:', error);
                        if (loadingState) loadingState.style.display = 'none';
                        if (errorState) {
                            errorState.style.display = 'block';
                            var errorMessageEl = document.getElementById('payslipsErrorMessage');
                            if (errorMessageEl) {
                                errorMessageEl.textContent = 'Failed to load approved payrolls: ' + error;
                            }
                        }
                    }
                });
            }

            /**
             * View payslip details
             */
            function viewPayslip(payslipId) {
                console.log('[viewPayslip] Viewing payslip:', payslipId);

                // Create modal overlay
                var existingModal = document.getElementById('payslipViewModal');
                if (existingModal) {
                    existingModal.remove();
                }

                var modalOverlay = document.createElement('div');
                modalOverlay.id = 'payslipViewModal';
                modalOverlay.style.cssText = 'position:fixed; top:0; left:0; width:100vw; height:100vh; background:rgba(0,0,0,0.7); z-index:99999; display:flex; justify-content:center; align-items:center; overflow:auto;';

                var modalContent = document.createElement('div');
                modalContent.style.cssText = 'background:white; width:90%; max-width:1000px; max-height:90vh; border-radius:12px; padding:30px; position:relative; overflow-y:auto; box-shadow:0 10px 40px rgba(0,0,0,0.3); margin:20px;';
                modalContent.innerHTML = '<div style="text-align:center; padding:40px;"><div style="font-size:24px;">Loading...</div><p>Loading payslip...</p></div>';

                modalOverlay.appendChild(modalContent);
                document.body.appendChild(modalOverlay);

                // Close on overlay click
                modalOverlay.addEventListener('click', function (e) {
                    if (e.target === modalOverlay) {
                        modalOverlay.remove();
                    }
                });

                // Fetch payslip content
                if (typeof $ === 'undefined') {
                    modalContent.innerHTML = '<button type="button" onclick="document.getElementById(\'payslipViewModal\').remove()" style="position:absolute; top:15px; right:15px; font-size:28px; cursor:pointer; background:none; border:none; color:#666;">&times;</button><div style="text-align:center; padding:40px; color:#991B1B;"><h2>Error</h2><p>jQuery is not loaded</p><button type="button" onclick="document.getElementById(\'payslipViewModal\').remove()" style="margin-top:20px; padding:10px 20px; background:#A44F56; color:white; border:none; border-radius:8px; cursor:pointer;">Close</button></div>';
                    return;
                }

                $.ajax({
                    type: 'GET',
                    url: '../Handler/GetPayslipContentHandler.ashx?id=' + encodeURIComponent(payslipId),
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    timeout: 30000,
                    success: function (response) {
                        if (response && response.success && response.htmlContent) {
                            modalContent.innerHTML = '<button type="button" onclick="document.getElementById(\'payslipViewModal\').remove()" style="position:absolute; top:15px; right:15px; font-size:28px; cursor:pointer; background:none; border:none; color:#666; width:40px; height:40px; line-height:40px; text-align:center; z-index:100000;">&times;</button>' + response.htmlContent;
                        } else {
                            modalContent.innerHTML = '<button type="button" onclick="document.getElementById(\'payslipViewModal\').remove()" style="position:absolute; top:15px; right:15px; font-size:28px; cursor:pointer; background:none; border:none; color:#666;">&times;</button><div style="text-align:center; padding:40px; color:#991B1B;"><h2>Error</h2><p>' + ((response && response.message) ? response.message : 'Failed to load payslip') + '</p><button type="button" onclick="document.getElementById(\'payslipViewModal\').remove()" style="margin-top:20px; padding:10px 20px; background:#A44F56; color:white; border:none; border-radius:8px; cursor:pointer;">Close</button></div>';
                        }
                    },
                    error: function (xhr, status, error) {
                        console.error('[viewPayslip] AJAX Error:', error);
                        modalContent.innerHTML = '<button type="button" onclick="document.getElementById(\'payslipViewModal\').remove()" style="position:absolute; top:15px; right:15px; font-size:28px; cursor:pointer; background:none; border:none; color:#666;">&times;</button><div style="text-align:center; padding:40px; color:#991B1B;"><h2>Error</h2><p>Failed to load payslip: ' + error + '</p><button type="button" onclick="document.getElementById(\'payslipViewModal\').remove()" style="margin-top:20px; padding:10px 20px; background:#A44F56; color:white; border:none; border-radius:8px; cursor:pointer;">Close</button></div>';
                    }
                });
            }

            /**
             * Download payslip
             */
            function downloadPayslip(payslipId) {
                console.log('[downloadPayslip] Downloading payslip:', payslipId);
                // TODO: Implement download functionality
                alert('Download payslip: ' + payslipId);
            }

            // Expose to global scope
            window.loadPayslips = loadPayslips;
            window.viewPayslip = viewPayslip;
            window.downloadPayslip = downloadPayslip;

            /**
             * Load Payroll History from PayRuns collection
             * Defined in head so it's available when switchTab calls it
             */
            function loadPayrollHistory() {
                console.log('[loadPayrollHistory] Starting to load payroll history...');

                // Show loading state
                var loadingState = document.getElementById('historyLoadingState');
                var errorState = document.getElementById('historyErrorState');
                var emptyState = document.getElementById('historyEmptyState');
                var tableContainer = document.getElementById('historyTableContainer');
                var tableBody = document.getElementById('historyTableBody');

                console.log('[loadPayrollHistory] Elements found:', {
                    loadingState: !!loadingState,
                    errorState: !!errorState,
                    emptyState: !!emptyState,
                    tableContainer: !!tableContainer,
                    tableBody: !!tableBody
                });

                if (!loadingState || !errorState || !emptyState || !tableContainer || !tableBody) {
                    console.warn('[loadPayrollHistory] Some elements not found, waiting for DOM...');
                    setTimeout(function () {
                        loadPayrollHistory();
                    }, 200);
                    return;
                }

                if (loadingState) loadingState.style.display = 'block';
                if (errorState) errorState.style.display = 'none';
                if (emptyState) emptyState.style.display = 'none';
                if (tableContainer) tableContainer.style.display = 'none';

                // Check if jQuery is available
                if (typeof $ === 'undefined') {
                    console.error('[loadPayrollHistory] jQuery is not loaded!');
                    if (loadingState) loadingState.style.display = 'none';
                    if (errorState) {
                        errorState.style.display = 'block';
                        var errorMessageEl = document.getElementById('historyErrorMessage');
                        if (errorMessageEl) {
                            errorMessageEl.textContent = 'jQuery is not loaded. Please refresh the page.';
                        }
                    }
                    return;
                }

                // Call Generic Handler instead of WebMethod (more reliable)
                // Try absolute path first, fallback to relative
                var handlerUrl = '/Handler/GetPayrollHistoryHandler.ashx';
                console.log('[loadPayrollHistory] Making AJAX call to: ' + handlerUrl);
                $.ajax({
                    type: 'GET',
                    url: handlerUrl,
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    timeout: 30000, // 30 second timeout
                    beforeSend: function () {
                        console.log('[loadPayrollHistory] AJAX request starting...');
                    },
                    success: function (response) {
                        console.log('[loadPayrollHistory] AJAX SUCCESS - Response received');
                        console.log('[loadPayrollHistory] Response received:', response);
                        console.log('[loadPayrollHistory] Response type:', typeof response);
                        console.log('[loadPayrollHistory] Response stringified:', JSON.stringify(response));

                        // Hide loading state immediately
                        if (loadingState) {
                            loadingState.style.display = 'none';
                            loadingState.setAttribute('style', 'display:none !important;');
                        }

                        // Handler returns direct response (no .d wrapper)
                        // If response is a string, parse it
                        var result = response;
                        if (typeof response === 'string') {
                            try {
                                result = JSON.parse(response);
                                console.log('[loadPayrollHistory] Parsed response from string:', result);
                            } catch (e) {
                                console.error('[loadPayrollHistory] Failed to parse response:', e);
                            }
                        }

                        console.log('[loadPayrollHistory] Result:', result);
                        console.log('[loadPayrollHistory] Result.success:', result ? result.success : 'null');
                        console.log('[loadPayrollHistory] Result.data:', result ? result.data : 'null');
                        console.log('[loadPayrollHistory] Result.data type:', result && result.data ? typeof result.data : 'null');
                        console.log('[loadPayrollHistory] Result.data is array:', result && result.data ? Array.isArray(result.data) : 'null');

                        // Check for success (handle both boolean true and string "true")
                        var isSuccess = result && (result.success === true || result.success === 'true' || result.success === 1);
                        console.log('[loadPayrollHistory] Is success:', isSuccess);

                        if (isSuccess) {
                            var historyData = result.data || [];
                            console.log('[loadPayrollHistory] Found', historyData.length, 'payroll records');
                            console.log('[loadPayrollHistory] History data:', historyData);

                            if (historyData.length === 0) {
                                // Show empty state
                                console.log('[loadPayrollHistory] No data, showing empty state');
                                if (emptyState) {
                                    emptyState.style.display = 'block';
                                    emptyState.setAttribute('style', 'display:block !important;');
                                }
                                if (tableContainer) {
                                    tableContainer.style.display = 'none';
                                    tableContainer.setAttribute('style', 'display:none !important;');
                                }
                            } else {
                                console.log('[loadPayrollHistory] Populating table with', historyData.length, 'records');
                                // Populate table
                                if (tableBody) {
                                    tableBody.innerHTML = '';

                                    historyData.forEach(function (item, index) {
                                        console.log('[loadPayrollHistory] Processing item', index, ':', item);
                                        var row = document.createElement('tr');

                                        // Format status badge
                                        var statusBg = '';
                                        var statusColor = '';

                                        switch (item.status) {
                                            case 'Approved':
                                                statusBg = '#D1FAE5';
                                                statusColor = '#065F46';
                                                break;
                                            case 'Draft':
                                                statusBg = '#FEF3C7';
                                                statusColor = '#92400E';
                                                break;
                                            case 'Calculated':
                                                statusBg = '#DBEAFE';
                                                statusColor = '#1E40AF';
                                                break;
                                            case 'Cancelled':
                                                statusBg = '#FEE2E2';
                                                statusColor = '#991B1B';
                                                break;
                                            default:
                                                statusBg = '#E5E7EB';
                                                statusColor = '#374151';
                                        }

                                        var grossAmount = parseFloat(item.totalGrossSalary || 0);
                                        var deductionsAmount = parseFloat(item.totalDeductions || 0);
                                        var netAmount = parseFloat(item.totalNetSalary || 0);

                                        row.innerHTML =
                                            '<td>' + (item.period || 'N/A') + '</td>' +
                                            '<td>' + (item.totalEmployees || 0) + '</td>' +
                                            '<td class="amount-green">&#8369;' + grossAmount.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td>' +
                                            '<td class="amount-gray">&#8369;' + deductionsAmount.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td>' +
                                            '<td class="amount-blue">&#8369;' + netAmount.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</td>' +
                                            '<td>' + (item.approvedAt || item.createdAt || 'N/A') + '</td>' +
                                            '<td>' + (item.approvedBy || 'N/A') + '</td>' +
                                            '<td><span class="status-badge" style="background:' + statusBg + ';color:' + statusColor + ';">' + (item.status || 'N/A') + '</span></td>' +
                                            '<td>' +
                                            '<button type="button" class="btn-icon-sm" title="View" onclick="viewPayrollHistory(\'' + item.id + '\')">' +
                                            '<svg class="svg-icon-sm" viewBox="0 0 24 24" fill="currentColor">' +
                                            '<path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/>' +
                                            '</svg>' +
                                            '</button>' +
                                            '<button type="button" class="btn-icon-sm" title="Download" onclick="downloadPayrollHistory(\'' + item.id + '\')">' +
                                            '<svg class="svg-icon-sm" viewBox="0 0 24 24" fill="currentColor">' +
                                            '<path d="M19 9h-4V3H9v6H5l7 7 7-7zM5 18v2h14v-2H5z"/>' +
                                            '</svg>' +
                                            '</button>' +
                                            '</td>';

                                        tableBody.appendChild(row);
                                    });
                                }

                                // SIMPLE SOLUTION: Create a new visible container and populate it with the table
                                console.log('[loadPayrollHistory] Creating simple visible table container...');

                                // Find or create a visible container after the tab navigation
                                var tabNavigation = document.querySelector('.tab-navigation');
                                var simpleContainer = document.getElementById('historySimpleContainer');

                                if (!simpleContainer && tabNavigation) {
                                    // Create a new simple container right after tab navigation
                                    simpleContainer = document.createElement('div');
                                    simpleContainer.id = 'historySimpleContainer';
                                    simpleContainer.style.cssText = 'display:block !important; width:100% !important; padding:40px; background:white; border-radius:20px; margin-top:20px; box-shadow:0 4px 6px rgba(0,0,0,0.1);';

                                    // Insert after tab navigation
                                    if (tabNavigation.nextSibling) {
                                        tabNavigation.parentElement.insertBefore(simpleContainer, tabNavigation.nextSibling);
                                    } else {
                                        tabNavigation.parentElement.appendChild(simpleContainer);
                                    }
                                    console.log('[loadPayrollHistory] Created simple container');
                                }

                                if (simpleContainer && historyData && historyData.length > 0) {
                                    // Clear and create table structure in simple container
                                    simpleContainer.innerHTML = '<h2 style="margin-bottom:30px; color:#A44F56; font-size:28px; font-weight:700;">Payroll History</h2>';

                                    // Create table
                                    var simpleTable = document.createElement('table');
                                    simpleTable.className = 'history-table';
                                    simpleTable.style.cssText = 'width:100%; border-collapse:collapse;';

                                    // Create thead
                                    var thead = document.createElement('thead');
                                    thead.innerHTML = '<tr>' +
                                        '<th style="padding:16px; background:linear-gradient(135deg, #A44F56 0%, #8B3E45 100%); color:white; font-weight:700; text-transform:uppercase; font-size:12px;">Period</th>' +
                                        '<th style="padding:16px; background:linear-gradient(135deg, #A44F56 0%, #8B3E45 100%); color:white; font-weight:700; text-transform:uppercase; font-size:12px;">Employees</th>' +
                                        '<th style="padding:16px; background:linear-gradient(135deg, #A44F56 0%, #8B3E45 100%); color:white; font-weight:700; text-transform:uppercase; font-size:12px;">Gross</th>' +
                                        '<th style="padding:16px; background:linear-gradient(135deg, #A44F56 0%, #8B3E45 100%); color:white; font-weight:700; text-transform:uppercase; font-size:12px;">Deductions</th>' +
                                        '<th style="padding:16px; background:linear-gradient(135deg, #A44F56 0%, #8B3E45 100%); color:white; font-weight:700; text-transform:uppercase; font-size:12px;">Net</th>' +
                                        '<th style="padding:16px; background:linear-gradient(135deg, #A44F56 0%, #8B3E45 100%); color:white; font-weight:700; text-transform:uppercase; font-size:12px;">Date</th>' +
                                        '<th style="padding:16px; background:linear-gradient(135deg, #A44F56 0%, #8B3E45 100%); color:white; font-weight:700; text-transform:uppercase; font-size:12px;">By</th>' +
                                        '<th style="padding:16px; background:linear-gradient(135deg, #A44F56 0%, #8B3E45 100%); color:white; font-weight:700; text-transform:uppercase; font-size:12px;">Status</th>' +
                                        '<th style="padding:16px; background:linear-gradient(135deg, #A44F56 0%, #8B3E45 100%); color:white; font-weight:700; text-transform:uppercase; font-size:12px;">Actions</th>' +
                                        '</tr>';

                                    // Create tbody
                                    var tbody = document.createElement('tbody');

                                    // Populate rows from historyData
                                    historyData.forEach(function (item) {
                                        var row = document.createElement('tr');
                                        row.style.cssText = 'border-bottom:1px solid #F9D2D6;';

                                        var statusBg = '#E5E7EB';
                                        var statusColor = '#374151';
                                        switch (item.status) {
                                            case 'Approved':
                                                statusBg = '#D1FAE5';
                                                statusColor = '#065F46';
                                                break;
                                            case 'Draft':
                                                statusBg = '#FEF3C7';
                                                statusColor = '#92400E';
                                                break;
                                            case 'Calculated':
                                                statusBg = '#DBEAFE';
                                                statusColor = '#1E40AF';
                                                break;
                                        }

                                        // Create cells
                                        var periodCell = document.createElement('td');
                                        periodCell.style.cssText = 'padding:16px;';
                                        periodCell.textContent = item.period || 'N/A';

                                        var employeesCell = document.createElement('td');
                                        employeesCell.style.cssText = 'padding:16px;';
                                        employeesCell.textContent = item.totalEmployees || 0;

                                        var grossCell = document.createElement('td');
                                        grossCell.style.cssText = 'padding:16px; color:#22C55E; font-weight:700;';
                                        var grossAmount = parseFloat(item.totalGrossSalary || 0);
                                        grossCell.innerHTML = '&#8369;' + grossAmount.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

                                        var deductionsCell = document.createElement('td');
                                        deductionsCell.style.cssText = 'padding:16px; color:#9CA3AF;';
                                        var deductionsAmount = parseFloat(item.totalDeductions || 0);
                                        deductionsCell.innerHTML = '&#8369;' + deductionsAmount.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

                                        var netCell = document.createElement('td');
                                        netCell.style.cssText = 'padding:16px; color:#A44F56; font-weight:700;';
                                        var netAmount = parseFloat(item.totalNetSalary || 0);
                                        netCell.innerHTML = '&#8369;' + netAmount.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

                                        var dateCell = document.createElement('td');
                                        dateCell.style.cssText = 'padding:16px;';
                                        dateCell.textContent = item.approvedAt || item.createdAt || 'N/A';

                                        var byCell = document.createElement('td');
                                        byCell.style.cssText = 'padding:16px;';
                                        byCell.textContent = item.approvedBy || 'N/A';

                                        var statusCell = document.createElement('td');
                                        statusCell.style.cssText = 'padding:16px;';
                                        var statusSpan = document.createElement('span');
                                        statusSpan.style.cssText = 'background:' + statusBg + ';color:' + statusColor + ';padding:4px 12px;border-radius:12px;font-size:12px;font-weight:600;';
                                        statusSpan.textContent = item.status || 'N/A';
                                        statusCell.appendChild(statusSpan);

                                        var actionsCell = document.createElement('td');
                                        actionsCell.style.cssText = 'padding:16px;';
                                        var viewButton = document.createElement('button');
                                        viewButton.type = 'button';
                                        viewButton.style.cssText = 'padding:8px 16px;background:#F3F4F6;border:none;border-radius:6px;cursor:pointer;margin-right:8px;';
                                        viewButton.textContent = 'View';
                                        viewButton.addEventListener('click', function () {
                                            if (typeof window.viewPayrollHistory === 'function') {
                                                window.viewPayrollHistory(item.id);
                                            } else {
                                                console.error('[loadPayrollHistory] viewPayrollHistory function not found!');
                                                alert('View function not available. Please refresh the page.');
                                            }
                                        });
                                        actionsCell.appendChild(viewButton);

                                        row.appendChild(periodCell);
                                        row.appendChild(employeesCell);
                                        row.appendChild(grossCell);
                                        row.appendChild(deductionsCell);
                                        row.appendChild(netCell);
                                        row.appendChild(dateCell);
                                        row.appendChild(byCell);
                                        row.appendChild(statusCell);
                                        row.appendChild(actionsCell);

                                        tbody.appendChild(row);
                                    });

                                    simpleTable.appendChild(thead);
                                    simpleTable.appendChild(tbody);
                                    simpleContainer.appendChild(simpleTable);

                                    // Show the simple container
                                    simpleContainer.style.setProperty('display', 'block', 'important');
                                    simpleContainer.style.setProperty('visibility', 'visible', 'important');

                                    console.log('[loadPayrollHistory] Simple table created and populated with', historyData.length, 'rows');
                                } else {
                                    console.error('[loadPayrollHistory] Could not create simple container or no data!');
                                }

                                // First, hide all other tabs explicitly
                                var allTabs = document.querySelectorAll('.tab-content');
                                for (var i = 0; i < allTabs.length; i++) {
                                    if (allTabs[i].id !== 'history') {
                                        allTabs[i].classList.remove('active');
                                        allTabs[i].style.setProperty('display', 'none', 'important');
                                    }
                                }

                                var historyTabContent = document.getElementById('history');
                                if (historyTabContent) {
                                    // Check if history is actually nested inside payroll-gen
                                    var parent = historyTabContent.parentElement;
                                    var isNested = false;
                                    var checkParent = parent;
                                    while (checkParent && checkParent !== document.body) {
                                        if (checkParent.id === 'payroll-gen') {
                                            isNested = true;
                                            console.warn('[loadPayrollHistory] History tab IS nested inside payroll-gen! Moving it...');
                                            // Move history to be after payslips tab
                                            var payslipsTab = document.getElementById('payslips');
                                            var payrollContainer = document.querySelector('.payroll-container');
                                            if (payslipsTab && payslipsTab.parentElement) {
                                                payslipsTab.parentElement.insertBefore(historyTabContent, payslipsTab.nextSibling);
                                                console.log('[loadPayrollHistory] History tab moved to be sibling of payslips');
                                            } else if (payrollContainer) {
                                                payrollContainer.appendChild(historyTabContent);
                                                console.log('[loadPayrollHistory] History tab moved to payroll-container');
                                            }

                                            // Force reflow after move
                                            historyTabContent.offsetHeight;

                                            // Verify the move worked
                                            var newParent = historyTabContent.parentElement;
                                            var stillNested = false;
                                            var verifyParent = newParent;
                                            while (verifyParent && verifyParent !== document.body) {
                                                if (verifyParent.id === 'payroll-gen') {
                                                    stillNested = true;
                                                    console.error('[loadPayrollHistory] Still nested after move!');
                                                    break;
                                                }
                                                verifyParent = verifyParent.parentElement;
                                            }
                                            if (!stillNested) {
                                                console.log('[loadPayrollHistory] Move verified - history is no longer nested');
                                            }
                                            break;
                                        }
                                        checkParent = checkParent.parentElement;
                                    }

                                    historyTabContent.classList.add('active');
                                    historyTabContent.style.setProperty('display', 'block', 'important');
                                    historyTabContent.style.setProperty('visibility', 'visible', 'important');
                                    historyTabContent.style.setProperty('opacity', '1', 'important');
                                    historyTabContent.style.setProperty('width', '100%', 'important');
                                    historyTabContent.style.setProperty('min-width', '100%', 'important');
                                    historyTabContent.style.setProperty('min-height', '400px', 'important');
                                    historyTabContent.style.setProperty('position', 'relative', 'important');
                                    historyTabContent.style.setProperty('z-index', '100', 'important');
                                    console.log('[loadPayrollHistory] History tab-content display set to block');
                                    console.log('[loadPayrollHistory] History tab-content computed style:', window.getComputedStyle(historyTabContent).display);
                                    console.log('[loadPayrollHistory] History tab-content computed width:', window.getComputedStyle(historyTabContent).width);
                                    console.log('[loadPayrollHistory] History tab-content has active class:', historyTabContent.classList.contains('active'));
                                    console.log('[loadPayrollHistory] History tab-content visibility:', window.getComputedStyle(historyTabContent).visibility);
                                    console.log('[loadPayrollHistory] History tab-content opacity:', window.getComputedStyle(historyTabContent).opacity);

                                    // Also ensure main-content inside is visible and has dimensions
                                    var mainContent = historyTabContent.querySelector('.main-content');
                                    if (mainContent) {
                                        mainContent.style.setProperty('display', 'block', 'important');
                                        mainContent.style.setProperty('width', '100%', 'important');
                                        mainContent.style.setProperty('min-width', '100%', 'important');
                                        mainContent.style.setProperty('min-height', '400px', 'important');
                                        console.log('[loadPayrollHistory] Main-content inside history tab is visible');
                                        console.log('[loadPayrollHistory] Main-content width:', window.getComputedStyle(mainContent).width);
                                        console.log('[loadPayrollHistory] Main-content height:', window.getComputedStyle(mainContent).height);

                                        // Force reflow and check again
                                        mainContent.offsetHeight;
                                        var mainRect = mainContent.getBoundingClientRect();
                                        console.log('[loadPayrollHistory] Main-content bounding rect after reflow:', mainRect);

                                        if (mainRect.width === 0) {
                                            console.warn('[loadPayrollHistory] Main-content still has zero width, checking parent...');
                                            var mainParent = mainContent.parentElement;
                                            if (mainParent) {
                                                var parentRect = mainParent.getBoundingClientRect();
                                                console.log('[loadPayrollHistory] Main-content parent rect:', parentRect);
                                                if (parentRect.width === 0) {
                                                    mainParent.style.setProperty('width', '100%', 'important');
                                                    mainParent.style.setProperty('min-width', '100%', 'important');
                                                    console.log('[loadPayrollHistory] Fixed main-content parent width');
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    console.error('[loadPayrollHistory] History tab-content not found!');
                                }

                                // Also hide empty and error states with !important
                                if (emptyState) {
                                    emptyState.style.setProperty('display', 'none', 'important');
                                    console.log('[loadPayrollHistory] Empty state hidden, computed:', window.getComputedStyle(emptyState).display);
                                }
                                if (errorState) {
                                    errorState.style.setProperty('display', 'none', 'important');
                                    console.log('[loadPayrollHistory] Error state hidden, computed:', window.getComputedStyle(errorState).display);
                                }
                                if (loadingState) {
                                    loadingState.style.setProperty('display', 'none', 'important');
                                    console.log('[loadPayrollHistory] Loading state hidden, computed:', window.getComputedStyle(loadingState).display);
                                }

                                // Verify all states are hidden and table is visible
                                console.log('[loadPayrollHistory] Final state check:');
                                console.log('  - Loading state display:', loadingState ? window.getComputedStyle(loadingState).display : 'N/A');
                                console.log('  - Error state display:', errorState ? window.getComputedStyle(errorState).display : 'N/A');
                                console.log('  - Empty state display:', emptyState ? window.getComputedStyle(emptyState).display : 'N/A');
                                console.log('  - Table container display:', tableContainer ? window.getComputedStyle(tableContainer).display : 'N/A');
                                console.log('  - Table container height:', tableContainer ? window.getComputedStyle(tableContainer).height : 'N/A');
                                console.log('  - Table container width:', tableContainer ? window.getComputedStyle(tableContainer).width : 'N/A');
                                console.log('  - Table container position:', tableContainer ? window.getComputedStyle(tableContainer).position : 'N/A');
                                console.log('  - Table container z-index:', tableContainer ? window.getComputedStyle(tableContainer).zIndex : 'N/A');

                                // Check if table is actually in DOM and visible
                                if (tableContainer) {
                                    var rect = tableContainer.getBoundingClientRect();
                                    console.log('[loadPayrollHistory] Table container bounding rect:', {
                                        top: rect.top,
                                        left: rect.left,
                                        width: rect.width,
                                        height: rect.height,
                                        visible: rect.width > 0 && rect.height > 0
                                    });

                                    // Check parent elements
                                    var parent = tableContainer.parentElement;
                                    var parentChain = [];
                                    while (parent && parentChain.length < 5) {
                                        parentChain.push({
                                            tag: parent.tagName,
                                            id: parent.id,
                                            class: parent.className,
                                            display: window.getComputedStyle(parent).display,
                                            visibility: window.getComputedStyle(parent).visibility,
                                            opacity: window.getComputedStyle(parent).opacity
                                        });
                                        parent = parent.parentElement;
                                    }
                                    console.log('[loadPayrollHistory] Parent element chain:', parentChain);

                                    // Fix any parent that might be collapsed
                                    parentChain.forEach(function (p, idx) {
                                        if (p.display === 'none' || p.visibility === 'hidden' || parseFloat(p.opacity) === 0) {
                                            console.warn('[loadPayrollHistory] Problematic parent at index', idx, ':', p);
                                        }
                                    });
                                }

                                // Update pagination
                                var pagination = document.getElementById('historyPagination');
                                if (pagination) {
                                    pagination.innerHTML = 'Showing 1-' + historyData.length + ' of ' + historyData.length + ' entries';
                                }

                                console.log('[loadPayrollHistory] Table populated successfully. Rows in tableBody:', tableBody ? tableBody.children.length : 0);

                                // Additional debugging - check if table is actually visible
                                if (tableContainer) {
                                    var table = tableContainer.querySelector('.history-table');
                                    if (table) {
                                        console.log('[loadPayrollHistory] Table element found:', table);
                                        console.log('[loadPayrollHistory] Table display:', window.getComputedStyle(table).display);
                                        console.log('[loadPayrollHistory] Table visibility:', window.getComputedStyle(table).visibility);
                                        console.log('[loadPayrollHistory] Table rows count:', table.querySelectorAll('tbody tr').length);
                                        console.log('[loadPayrollHistory] First row HTML:', tableBody && tableBody.firstElementChild ? tableBody.firstElementChild.outerHTML.substring(0, 200) : 'No rows');
                                    } else {
                                        console.error('[loadPayrollHistory] Table element not found inside container!');
                                    }

                                    // Force dimensions if container is collapsed
                                    setTimeout(function () {
                                        // First, ensure payroll-gen is hidden and history is shown
                                        var payrollGenTab = document.getElementById('payroll-gen');
                                        if (payrollGenTab) {
                                            payrollGenTab.classList.remove('active');
                                            payrollGenTab.style.setProperty('display', 'none', 'important');
                                        }

                                        // Ensure history tab is visible
                                        var historyTab = document.getElementById('history');
                                        if (historyTab) {
                                            historyTab.classList.add('active');
                                            historyTab.style.setProperty('display', 'block', 'important');
                                            historyTab.style.setProperty('width', '100%', 'important');
                                            historyTab.style.setProperty('min-width', '100%', 'important');
                                            historyTab.style.setProperty('min-height', '400px', 'important');
                                        }

                                        var rect = tableContainer.getBoundingClientRect();
                                        if (rect.width === 0 || rect.height === 0) {
                                            console.warn('[loadPayrollHistory] Container still collapsed, forcing dimensions...');
                                            tableContainer.style.setProperty('width', '100%', 'important');
                                            tableContainer.style.setProperty('min-width', '100%', 'important');
                                            tableContainer.style.setProperty('min-height', '200px', 'important');

                                            // Fix all parent elements in the chain
                                            var current = tableContainer;
                                            var depth = 0;
                                            while (current && current.parentElement && depth < 6) {
                                                current = current.parentElement;
                                                var parentRect = current.getBoundingClientRect();
                                                var parentStyle = window.getComputedStyle(current);

                                                // Skip payroll-gen tab - it should be hidden
                                                if (current.id === 'payroll-gen') {
                                                    console.log('[loadPayrollHistory] Skipping payroll-gen tab (should be hidden)');
                                                    depth++;
                                                    continue;
                                                }

                                                if (parentRect.width === 0 || (parentStyle.display === 'none' && current.id !== 'payroll-gen')) {
                                                    console.log('[loadPayrollHistory] Fixing parent at depth', depth, ':', current.tagName, current.id, current.className);

                                                    if (parentStyle.display === 'none' && current.id === 'history') {
                                                        // This is the history tab-content, it should be visible
                                                        current.style.setProperty('display', 'block', 'important');
                                                    }

                                                    if (parentRect.width === 0) {
                                                        current.style.setProperty('width', '100%', 'important');
                                                        current.style.setProperty('min-width', '100%', 'important');
                                                    }

                                                    if (parentRect.height === 0 && (current.classList.contains('main-content') || current.id === 'history')) {
                                                        current.style.setProperty('min-height', '400px', 'important');
                                                    }
                                                }
                                                depth++;
                                            }

                                            // Force reflow
                                            tableContainer.offsetHeight;

                                            // Check again
                                            var newRect = tableContainer.getBoundingClientRect();
                                            console.log('[loadPayrollHistory] After fix - container rect:', {
                                                width: newRect.width,
                                                height: newRect.height,
                                                visible: newRect.width > 0 && newRect.height > 0
                                            });
                                        }
                                    }, 100);
                                }

                                // Force a reflow to ensure rendering
                                if (tableContainer) {
                                    tableContainer.offsetHeight; // Force reflow
                                }
                            }
                        } else {
                            // Show error
                            var errorMsg = (result && result.message) ? result.message : 'Failed to load payroll history';
                            console.error('[loadPayrollHistory] Error:', errorMsg);
                            console.error('[loadPayrollHistory] Full response:', response);

                            if (errorState) {
                                errorState.style.display = 'block';
                                var errorMessageEl = document.getElementById('historyErrorMessage');
                                if (errorMessageEl) {
                                    errorMessageEl.textContent = errorMsg;
                                }
                            }
                        }
                    },
                    error: function (xhr, status, error) {
                        console.error('[loadPayrollHistory] AJAX Error occurred!');
                        console.error('[loadPayrollHistory] Status:', status);
                        console.error('[loadPayrollHistory] Error:', error);
                        console.error('[loadPayrollHistory] Status Code:', xhr.status);
                        console.error('[loadPayrollHistory] Response Text:', xhr.responseText);
                        console.error('[loadPayrollHistory] Ready State:', xhr.readyState);
                        console.error('[loadPayrollHistory] Full XHR:', xhr);

                        // Try to parse response if it's JSON
                        if (xhr.responseText) {
                            try {
                                var errorResponse = JSON.parse(xhr.responseText);
                                console.error('[loadPayrollHistory] Parsed error response:', errorResponse);
                            } catch (e) {
                                console.error('[loadPayrollHistory] Response is not JSON, raw text:', xhr.responseText.substring(0, 500));
                            }
                        }

                        if (loadingState) loadingState.style.display = 'none';
                        if (errorState) {
                            errorState.style.display = 'block';
                            var errorMessageEl = document.getElementById('historyErrorMessage');
                            if (errorMessageEl) {
                                var errorText = 'Failed to load payroll history. ';
                                if (xhr.status === 500) {
                                    errorText += 'Server error. Check console for details.';
                                } else if (xhr.status === 404) {
                                    errorText += 'WebMethod not found.';
                                } else {
                                    errorText += 'Error: ' + error + ' (Status: ' + xhr.status + ')';
                                }
                                errorMessageEl.textContent = errorText;
                            }
                        }
                    },
                    complete: function (xhr, status) {
                        console.log('[loadPayrollHistory] AJAX request completed');
                        console.log('[loadPayrollHistory] Final status:', status);
                        console.log('[loadPayrollHistory] Final ready state:', xhr.readyState);
                    }
                });
            }

            // Make function globally available
            window.loadPayrollHistory = loadPayrollHistory;
        </script>

        <style>
            /* Color Palette */
            :root {
                --primary-burgundy: #A36A66;
                /* Main UI color */
                --dark-brown: #5C4F4E;
                /* Slightly warmer dark (harmonizes with #A36A66) */
                --light-pink: #C49A99;
                /* Lighter tint of primary */
                --medium-burgundy: #8B5A58;
                /* Darker active/completed state */
                --rose-pink: #F8ECEB;
                /* Very soft warm neutral (replaces pink) */
                --background-pink: #FFB3BA;
                /* Keep original bg gradient start (optional) */
            }

            /* SVG Icon Styles */
            .svg-icon {
                width: 18px;
                height: 18px;
                fill: currentColor;
                vertical-align: middle;
                display: inline-block;
            }

            .svg-icon-sm {
                width: 16px;
                height: 16px;
            }

            .svg-icon-lg {
                width: 24px;
                height: 24px;
            }

            /* Subtle Animations */
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

            .stat-card {
                animation: fadeIn 0.3s ease-out;
            }

            .stat-card:hover {
                transform: translateY(-3px);
                box-shadow: 0 8px 16px rgba(163, 106, 102, 0.2);
            }

            .btn:hover {
                transform: translateY(-2px);
            }

            .btn:active {
                transform: translateY(0);
            }

            /* Reset and Base Styles - Scoped to avoid conflicts with masterpage */
            .payroll-container * {
                box-sizing: border-box;
            }

            .payroll-container {
                max-width: 1400px;
                margin: 0 auto;
                padding: 30px 20px;
                width: 100%;
                box-sizing: border-box;
                background: transparent;
                min-height: calc(100vh - 80px);
            }

            /* Stats Cards */
            .stats-grid {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 20px;
                margin-bottom: 30px;
            }

            .stat-card {
                background: white;
                border-radius: 16px;
                padding: 25px;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                transition: all 0.3s;
            }

            .stat-header {
                font-size: 14px;
                color: var(--primary-burgundy);
                font-weight: 600;
                margin-bottom: 15px;
                text-align: center;
            }

            .stat-value {
                font-size: 32px;
                font-weight: 700;
                color: #1a1a1a;
                text-align: center;
            }

            .stat-label {
                font-size: 13px;
                color: var(--medium-burgundy);
                text-align: center;
                margin-top: 8px;
            }

            /* Tab Navigation */
            .tab-navigation {
                display: flex;
                gap: 20px;
                margin-bottom: 30px;
                justify-content: center;
                align-items: center;
            }

            .tab-btn {
                padding: 18px 40px;
                background: white;
                border: none;
                border-radius: 50px;
                font-size: 18px;
                font-weight: 700;
                color: var(--medium-burgundy);
                cursor: pointer;
                transition: all 0.3s;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                white-space: nowrap;
                min-width: 280px;
                text-align: center;
            }

            .tab-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15);
            }

            .tab-btn.active {
                background: linear-gradient(135deg, var(--medium-burgundy) 0%, var(--primary-burgundy) 100%);
                color: white;
            }

            /* Tab Content - Hide by default, show when active */
            .tab-content {
                display: none !important;
            }

            .tab-content.active {
                display: block !important;
            }

            /* Force history tab to be visible when active */
            #history.tab-content.active {
                display: block !important;
                visibility: visible !important;
                opacity: 1 !important;
            }

            /* Main Content Area - Scoped to payroll container only */
            .payroll-container .main-content {
                background: white;
                border-radius: 20px;
                padding: 40px;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                min-height: 600px;
                margin: 0 auto;
                max-width: 100%;
                box-sizing: border-box;
                display: block !important;
                width: 100% !important;
            }

            /* Ensure history tab main-content is visible */
            #history .main-content {
                display: block !important;
                width: 100% !important;
                min-height: 400px !important;
            }

            /* Stats Cards */
            .stats-grid {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 20px;
                margin-bottom: 30px;
            }

            .stat-card {
                background: white;
                border-radius: 16px;
                padding: 25px;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                transition: all 0.3s;
            }

            .stat-header {
                font-size: 14px;
                color: var(--primary-burgundy);
                font-weight: 600;
                margin-bottom: 15px;
                text-align: center;
            }

            .stat-value {
                font-size: 32px;
                font-weight: 700;
                color: #1a1a1a;
                text-align: center;
            }

            .stat-label {
                font-size: 13px;
                color: var(--medium-burgundy);
                text-align: center;
                margin-top: 8px;
            }

            /* Tab Navigation */
            .tab-navigation {
                display: flex;
                gap: 20px;
                margin-bottom: 30px;
                justify-content: center;
                align-items: center;
            }

            .tab-btn {
                padding: 18px 40px;
                background: white;
                border: none;
                border-radius: 50px;
                font-size: 18px;
                font-weight: 700;
                color: var(--medium-burgundy);
                cursor: pointer;
                transition: all 0.3s;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                white-space: nowrap;
                min-width: 280px;
                text-align: center;
            }

            .tab-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15);
            }

            .tab-btn.active {
                background: linear-gradient(135deg, var(--medium-burgundy) 0%, var(--primary-burgundy) 100%);
                color: white;
            }

            /* Tab Content - Hide by default, show when active */
            .tab-content {
                display: none !important;
            }

            .tab-content.active {
                display: block !important;
            }

            /* Force history tab to be visible when active */
            #history.tab-content.active {
                display: block !important;
                visibility: visible !important;
                opacity: 1 !important;
            }

            /* Main Content Area - Scoped to payroll container only */
            .payroll-container .main-content {
                background: white;
                border-radius: 20px;
                padding: 40px;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                min-height: 600px;
                margin: 0 auto;
                max-width: 100%;
                box-sizing: border-box;
            }

            /* Stepper Styles */
            .stepper-container {
                background: white;
                border-radius: 16px;
                padding: 30px;
                box-shadow: 0 2px 4px rgba(0, 0, 0, 0.08);
                margin-bottom: 30px;
            }

            .stepper {
                display: flex;
                justify-content: space-between;
                align-items: center;
                position: relative;
            }

            .step {
                display: flex;
                flex-direction: column;
                align-items: center;
                flex: 1;
                position: relative;
            }

            .step-circle {
                width: 60px;
                height: 60px;
                border-radius: 50%;
                background: #E5E7EB;
                color: #9CA3AF;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 700;
                font-size: 20px;
                z-index: 2;
                position: relative;
                border: 4px solid white;
                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            }

            .step.active .step-circle {
                background: linear-gradient(135deg, var(--medium-burgundy) 0%, var(--primary-burgundy) 100%);
                color: white;
            }

            .step.completed .step-circle {
                background: linear-gradient(135deg, var(--medium-burgundy) 0%, var(--primary-burgundy) 100%);
                color: white;
            }

            .step-label {
                margin-top: 12px;
                font-size: 14px;
                color: #6B7280;
                font-weight: 600;
            }

            .step.active .step-label {
                color: var(--primary-burgundy);
                font-weight: 700;
            }

            .step-line {
                position: absolute;
                top: 30px;
                left: 50%;
                width: 100%;
                height: 4px;
                background: #E5E7EB;
                z-index: 1;
            }

            .step.completed .step-line {
                background: linear-gradient(90deg, var(--medium-burgundy) 0%, var(--primary-burgundy) 100%);
            }

            .step:last-child .step-line {
                display: none;
            }

            /* Content Container */
            .step-content {
                display: none;
            }

            .step-content.active {
                display: block;
            }

            .step-title {
                font-size: 28px;
                font-weight: 700;
                color: var(--dark-brown);
                margin-bottom: 30px;
            }

            /* Form Controls */
            .form-group {
                margin-bottom: 25px;
            }

            .form-label {
                display: block;
                font-size: 14px;
                font-weight: 600;
                color: var(--dark-brown);
                margin-bottom: 8px;
            }

            .form-control {
                width: 100%;
                padding: 14px 18px;
                border: 2px solid var(--rose-pink);
                border-radius: 12px;
                font-size: 15px;
                transition: all 0.3s;
                background: white;
            }

            .form-control:focus {
                outline: none;
                border-color: var(--primary-burgundy);
                box-shadow: 0 0 0 4px rgba(164, 79, 86, 0.1);
            }

            .form-row {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
            }

            /* Search Bar */
            .search-filter-container {
                display: flex;
                gap: 15px;
                margin-bottom: 25px;
                flex-wrap: wrap;
            }

            .search-box {
                flex: 1;
                position: relative;
                min-width: 250px;
            }

            .search-icon {
                position: absolute;
                left: 18px;
                top: 50%;
                transform: translateY(-50%);
                color: var(--primary-burgundy);
                font-size: 18px;
            }

            .search-input {
                width: 100%;
                padding: 14px 18px 14px 50px;
                border: 2px solid var(--rose-pink);
                border-radius: 12px;
                font-size: 15px;
            }

            .search-input:focus {
                outline: none;
                border-color: var(--primary-burgundy);
            }

            .filter-select {
                padding: 14px 18px;
                border: 2px solid var(--rose-pink);
                border-radius: 12px;
                font-size: 15px;
                background: white;
            }

            /* Employee Selection */
            .select-all-container {
                padding: 18px;
                background: linear-gradient(135deg, var(--light-pink) 0%, var(--rose-pink) 100%);
                border-radius: 12px;
                margin-bottom: 20px;
            }

            .checkbox-label {
                display: flex;
                align-items: center;
                gap: 12px;
                font-weight: 600;
                color: var(--dark-brown);
                cursor: pointer;
            }

            .checkbox {
                width: 22px;
                height: 22px;
                cursor: pointer;
                accent-color: var(--primary-burgundy);
            }

            /* Employee Cards */
            .employee-card {
                border: 2px solid var(--rose-pink);
                border-radius: 12px;
                padding: 20px;
                margin-bottom: 15px;
                display: flex;
                align-items: center;
                gap: 15px;
                transition: all 0.3s;
                background: white;
            }

            .employee-card:hover {
                box-shadow: 0 4px 12px rgba(164, 79, 86, 0.2);
                transform: translateY(-2px);
            }

            .employee-card.selected {
                border-color: var(--primary-burgundy);
                background: linear-gradient(135deg, #FFF5F5 0%, #FFE4E6 100%);
                border-width: 3px;
            }

            .employee-info {
                display: grid;
                grid-template-columns: 120px 200px 150px 150px 120px;
                gap: 20px;
                flex: 1;
                align-items: center;
            }

            .info-item {
                display: flex;
                flex-direction: column;
            }

            .info-label {
                font-size: 11px;
                color: var(--primary-burgundy);
                text-transform: uppercase;
                margin-bottom: 4px;
                font-weight: 600;
            }

            .info-value {
                font-size: 15px;
                color: var(--dark-brown);
                font-weight: 600;
            }

            .badge {
                display: inline-block;
                padding: 6px 14px;
                border-radius: 20px;
                font-size: 12px;
                font-weight: 700;
            }

            .badge-regular {
                background: #D1FAE5;
                color: #065F46;
            }

            .badge-contractual {
                background: #FEE2E2;
                color: #991B1B;
            }

            /* Computation Display */
            .computation-status {
                padding: 18px 24px;
                background: linear-gradient(135deg, var(--light-pink) 0%, var(--rose-pink) 100%);
                border-left: 5px solid var(--primary-burgundy);
                border-radius: 12px;
                margin-bottom: 30px;
                color: var(--dark-brown);
                font-weight: 600;
            }

            .employee-computation {
                border: 2px solid var(--rose-pink);
                border-radius: 16px;
                padding: 30px;
                margin-bottom: 25px;
                background: white;
            }

            .computation-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 25px;
                padding-bottom: 20px;
                border-bottom: 2px solid var(--rose-pink);
            }

            .employee-name {
                font-size: 20px;
                font-weight: 700;
                color: var(--dark-brown);
            }

            .status-badge {
                padding: 8px 18px;
                background: #D1FAE5;
                color: #065F46;
                border-radius: 8px;
                font-size: 13px;
                font-weight: 700;
            }

            .computation-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 40px;
            }

            .computation-section {
                display: flex;
                flex-direction: column;
            }

            .section-title {
                font-size: 14px;
                font-weight: 700;
                color: var(--primary-burgundy);
                margin-bottom: 18px;
                text-transform: uppercase;
                letter-spacing: 1px;
            }

            .computation-item {
                display: flex;
                justify-content: space-between;
                padding: 12px 0;
                border-bottom: 1px solid var(--rose-pink);
            }

            .computation-item:last-child {
                border-bottom: none;
            }

            .item-label {
                color: var(--dark-brown);
                font-size: 14px;
                font-weight: 500;
            }

            .item-value {
                color: var(--dark-brown);
                font-weight: 700;
                font-size: 15px;
            }

            .total-row {
                margin-top: 15px;
                padding-top: 18px;
                border-top: 3px solid var(--primary-burgundy);
            }

            .total-row .item-label {
                font-weight: 700;
                color: var(--dark-brown);
                font-size: 16px;
            }

            .total-row .item-value {
                font-size: 18px;
                color: #22C55E;
            }

            .pending-status {
                background: #FEF3C7;
                border: 2px solid #FCD34D;
                padding: 16px 20px;
                border-radius: 10px;
                margin-top: 15px;
            }

            .pending-status-text {
                color: #92400E;
                font-size: 13px;
                font-weight: 600;
            }

            .net-salary-box {
                background: linear-gradient(135deg, var(--light-pink) 0%, var(--rose-pink) 100%);
                padding: 18px;
                border-radius: 12px;
                margin-top: 15px;
                border: 2px solid var(--primary-burgundy);
            }

            .net-salary-label {
                font-size: 13px;
                color: var(--dark-brown);
                margin-bottom: 6px;
                font-weight: 600;
            }

            .net-salary-value {
                font-size: 24px;
                font-weight: 700;
                color: var(--primary-burgundy);
            }

            .btn-details {
                padding: 8px 16px;
                background: #E5E7EB;
                border: none;
                border-radius: 8px;
                font-size: 13px;
                cursor: pointer;
                margin-top: 10px;
            }

            .computation-details {
                display: none;
                margin-top: 15px;
                padding: 15px;
                background: #fafafa;
                border-radius: 8px;
                font-size: 14px;
                line-height: 1.5;
            }

            /* Review Table */
            .review-table {
                width: 100%;
                border-collapse: collapse;
                margin-bottom: 30px;
                border-radius: 12px;
                overflow: hidden;
            }

            .review-table thead {
                background: linear-gradient(135deg, var(--medium-burgundy) 0%, var(--primary-burgundy) 100%);
            }

            .review-table th {
                padding: 18px;
                text-align: left;
                font-size: 13px;
                font-weight: 700;
                color: white;
                text-transform: uppercase;
            }

            .review-table td {
                padding: 20px 18px;
                border-bottom: 1px solid var(--rose-pink);
                font-size: 15px;
                color: var(--dark-brown);
            }

            .review-table tbody tr:hover {
                background: linear-gradient(135deg, #FFF5F5 0%, #FFE4E6 100%);
            }

            .amount-green {
                color: #22C55E;
                font-weight: 700;
            }

            .amount-blue {
                color: var(--primary-burgundy);
                font-weight: 700;
            }

            .amount-gray {
                color: #9CA3AF;
            }

            .edit-icon {
                color: var(--primary-burgundy);
                cursor: pointer;
                font-size: 20px;
            }

            .editable-cell input {
                display: none;
                width: 120px;
                font-weight: bold;
                border: 1px solid #ccc;
                padding: 4px 8px;
                border-radius: 4px;
            }

            .remarks-cell {
                color: #888;
                font-style: italic;
                cursor: text;
            }

            .total-row-table {
                font-weight: 700;
                font-size: 16px;
                background: linear-gradient(135deg, var(--light-pink) 0%, var(--rose-pink) 100%);
            }

            /* Success Message */
            .success-container {
                text-align: center;
                padding: 60px 40px;
            }

            .success-icon {
                width: 100px;
                height: 100px;
                background: linear-gradient(135deg, var(--light-pink) 0%, var(--rose-pink) 100%);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 25px;
                box-shadow: 0 8px 20px rgba(164, 79, 86, 0.3);
            }

            .checkmark {
                width: 60px;
                height: 60px;
                border: 5px solid var(--primary-burgundy);
                border-radius: 50%;
                position: relative;
            }

            .checkmark::after {
                content: '';
                position: absolute;
                left: 16px;
                top: 8px;
                width: 15px;
                height: 25px;
                border: solid var(--primary-burgundy);
                border-width: 0 5px 5px 0;
                transform: rotate(45deg);
            }

            .success-title {
                font-size: 28px;
                font-weight: 700;
                color: var(--primary-burgundy);
                margin-bottom: 12px;
            }

            .success-message {
                color: var(--dark-brown);
                font-size: 16px;
                margin-bottom: 40px;
            }

            .email-notification {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 22px;
                background: #F0FDF4;
                border: 2px solid #BBF7D0;
                border-radius: 12px;
                margin-bottom: 20px;
            }

            .email-info {
                display: flex;
                align-items: center;
                gap: 18px;
            }

            .file-details {
                display: flex;
                flex-direction: column;
            }

            .file-name {
                font-weight: 700;
                color: var(--dark-brown);
                margin-bottom: 4px;
                font-size: 16px;
            }

            .file-description {
                font-size: 13px;
                color: var(--medium-burgundy);
            }

            .email-icon {
                width: 50px;
                height: 50px;
                background: #22C55E;
                border-radius: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-size: 24px;
            }

            .sent-badge {
                padding: 8px 16px;
                background: #D1FAE5;
                color: #065F46;
                border-radius: 8px;
                font-size: 13px;
                font-weight: 700;
            }

            .status-info-box {
                background: #FEF3C7;
                border: 2px solid #FCD34D;
                padding: 22px;
                border-radius: 12px;
                margin-bottom: 30px;
            }

            .status-info-title span {
                background: linear-gradient(90deg, #3B82F6, #8B5CF6);
                color: white;
                padding: 4px 12px;
                border-radius: 20px;
                font-size: 14px;
                font-weight: bold;
            }

            .status-info-text {
                color: #92400E;
                font-size: 14px;
                margin-top: 8px;
            }

            /* Buttons */
            .button-container {
                display: flex;
                gap: 15px;
                margin-top: 35px;
                flex-wrap: wrap;
            }

            .btn {
                padding: 16px 36px;
                border: none;
                border-radius: 50px;
                font-size: 16px;
                font-weight: 700;
                cursor: pointer;
                transition: all 0.3s;
                display: inline-flex;
                align-items: center;
                gap: 10px;
                text-decoration: none;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            }

            .btn-primary {
                background: linear-gradient(135deg, var(--medium-burgundy) 0%, var(--primary-burgundy) 100%);
                color: white;
                flex: 1;
                min-width: 200px;
            }

            .btn-primary:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 16px rgba(164, 79, 86, 0.4);
            }

            .btn-success {
                background: linear-gradient(135deg, #22C55E 0%, #16A34A 100%);
                color: white;
                flex: 1;
                min-width: 200px;
            }

            .btn-success:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 16px rgba(34, 197, 94, 0.4);
            }

            .btn-secondary {
                background: white;
                color: var(--medium-burgundy);
                border: 2px solid var(--rose-pink);
                min-width: 200px;
            }

            .btn-secondary:hover {
                background: var(--light-pink);
                border-color: var(--primary-burgundy);
            }

            .btn-success {
                background: linear-gradient(135deg, #10B981 0%, #059669 100%);
                color: white;
                border: none;
                min-width: 180px;
            }

            .btn-success:hover {
                background: linear-gradient(135deg, #059669 0%, #047857 100%);
                transform: translateY(-2px);
                box-shadow: 0 6px 12px rgba(16, 185, 129, 0.3);
            }

            .btn-sm {
                padding: 10px 20px;
                font-size: 14px;
                min-width: auto;
            }

            .status-approved {
                background: #D1FAE5;
                color: #065F46;
            }

            .btn-icon {
                font-size: 18px;
            }

            /* Tab Content */
            .tab-content {
                display: none;
            }

            .tab-content.active {
                display: block;
            }

            /* Modals */
            .modal {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.5);
                z-index: 2000;
                justify-content: center;
                align-items: center;
            }

            .modal-content {
                background: white;
                width: 800px;
                max-width: 95%;
                border-radius: 16px;
                padding: 30px;
                position: relative;
            }

            .close-modal {
                position: absolute;
                top: 15px;
                right: 15px;
                font-size: 28px;
                cursor: pointer;
                background: none;
                border: none;
            }

            /* History Table */
            #historyTableContainer {
                display: block !important;
                width: 100% !important;
                min-width: 100% !important;
                min-height: 200px !important;
                overflow-x: auto;
                position: relative !important;
                z-index: 10 !important;
            }

            .history-table {
                width: 100%;
                border-collapse: collapse;
                background: white;
            }

            .history-table th,
            .history-table td {
                padding: 16px;
                border-bottom: 1px solid var(--rose-pink);
            }

            .history-table thead th {
                background: linear-gradient(135deg, var(--medium-burgundy) 0%, var(--primary-burgundy) 100%);
                color: white;
                font-weight: 700;
                text-transform: uppercase;
                font-size: 12px;
            }

            .history-table tbody tr:hover {
                background: #FFF5F5;
            }

            .btn-icon-sm {
                width: 32px;
                height: 32px;
                display: flex;
                align-items: center;
                justify-content: center;
                background: #F3F4F6;
                border-radius: 6px;
                cursor: pointer;
                font-size: 16px;
                color: var(--medium-burgundy);
            }

            .btn-icon-sm:hover {
                background: #E5E7EB;
            }

            /* Configuration Tab Styles */
            .config-tab-btn {
                padding: 12px 20px;
                background: white;
                border: none;
                border-bottom: 3px solid transparent;
                font-size: 14px;
                font-weight: 600;
                color: var(--medium-burgundy);
                cursor: pointer;
                transition: all 0.3s;
            }

            .config-tab-btn:hover {
                background: var(--rose-pink);
            }

            .config-tab-btn.active {
                color: var(--primary-burgundy);
                border-bottom-color: var(--primary-burgundy);
                background: var(--rose-pink);
            }

            .config-section {
                animation: fadeIn 0.3s;
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

            @media (max-width: 1200px) {
                .payroll-container {
                    padding: 20px;
                }

                .stats-grid {
                    grid-template-columns: repeat(2, 1fr);
                }
            }

            @media (max-width: 768px) {
                .payroll-container {
                    padding: 15px;
                }

                .stats-grid {
                    grid-template-columns: 1fr;
                }

                .tab-navigation {
                    flex-direction: column;
                }

                .form-row {
                    grid-template-columns: 1fr;
                }

                .computation-grid {
                    grid-template-columns: 1fr;
                }

                .employee-info {
                    grid-template-columns: 1fr;
                    gap: 10px;
                }

                .stepper {
                    flex-wrap: wrap;
                }

                .button-container {
                    flex-direction: column;
                }

                .btn {
                    min-width: auto;
                }
            }
        </style>
    </asp:Content>
    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        <div class="payroll-container">
            <!-- Stats Cards -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-header">Current Period</div>
                    <div class="stat-value" id="statPeriod">Jan 1&ndash;15, 2025</div>
                    <div class="stat-label"></div>
                </div>
                <div class="stat-card">
                    <div class="stat-header">Employees</div>
                    <div class="stat-value" id="statEmployees">Loading...</div>
                    <div class="stat-label"></div>
                </div>
                <div class="stat-card">
                    <div class="stat-header">Total Gross</div>
                    <div class="stat-value" id="statGross">&#8369;0.00</div>
                    <div class="stat-label"></div>
                </div>
                <div class="stat-card">
                    <div class="stat-header">Status</div>
                    <div class="stat-value" id="statStatus">Draft</div>
                    <div class="stat-label"></div>
                </div>
            </div>
            <!-- Tab Navigation -->
            <div class="tab-navigation">
                <button type="button" class="tab-btn active" data-tab="payroll-gen"
                    onclick="switchTab('payroll-gen')">Payroll Generation</button>
                <button type="button" class="tab-btn" data-tab="configuration"
                    onclick="switchTab('configuration')">Payroll Configuration</button>
                <button type="button" class="tab-btn" data-tab="payslips"
                    onclick="switchTab('payslips')">Payslips</button>
                <button type="button" class="tab-btn" data-tab="history" onclick="switchTab('history')">History</button>
            </div>

            <!-- Payroll Configuration Tab (NEW - Function 6.1) -->
            <div id="configuration" class="tab-content">
                <div class="main-content">
                    <h2 class="step-title">Payroll Configuration & Master Data (Function 6.1)</h2>
                    <p style="color:#666; margin-bottom:30px;">Manage employee salary setup, allowances, deductions, and
                        overtime rates. This is the master data for all payroll calculations.</p>

                    <!-- Action Buttons -->
                    <div style="display:flex; gap:15px; margin-bottom:25px;">
                        <button type="button" class="btn btn-primary" id="btnAddNewConfig"
                            onclick="handleAddNewConfig()">
                            + Add New Configuration
                        </button>
                        <button type="button" class="btn btn-secondary" onclick="loadPayrollConfigurations()">
                            Refresh
                        </button>
                        <button type="button" class="btn btn-secondary" onclick="exportConfigurationsCSV()">
                            Export CSV
                        </button>
                    </div>

                    <!-- Search and Filter -->
                    <div class="search-filter-container">
                        <div class="search-box">
                            <span class="search-icon">Search</span>
                            <input type="text" class="search-input" placeholder="Search by name or employee number..."
                                id="searchConfig" onkeyup="filterConfigurations()">
                        </div>
                        <select id="filterConfigDept" class="filter-select" onchange="filterConfigurations()">
                            <option value="">All Departments</option>
                            <option value="IT">IT</option>
                            <option value="HR">HR</option>
                            <option value="Finance">Finance</option>
                            <option value="Operations">Operations</option>
                            <option value="Sales">Sales</option>
                        </select>
                    </div>

                    <!-- Loading State -->
                    <div id="configLoadingState" style="text-align:center; padding:40px;">
                        <div style="font-size:48px;">Loading...</div>
                        <p style="color:#666; margin-top:10px;">Loading configurations from database...</p>
                    </div>

                    <!-- Error State -->
                    <div id="configErrorState"
                        style="display:none; text-align:center; padding:40px; background:#FEE2E2; border-radius:12px;">
                        <div style="font-size:48px;">Error</div>
                        <p style="color:#991B1B; margin-top:10px; font-weight:600;">Failed to load configurations</p>
                        <p id="configErrorMessage" style="color:#666; font-size:14px;"></p>
                        <button type="button" class="btn btn-primary" onclick="loadPayrollConfigurations()"
                            style="margin-top:20px;">
                            Retry
                        </button>
                    </div>

                    <!-- Configurations Table -->
                    <div id="configTableContainer" style="display:none;">
                        <table class="review-table" id="configTable">
                            <thead>
                                <tr>
                                    <th>Emp No.</th>
                                    <th>Name</th>
                                    <th>Department</th>
                                    <th>Basic Salary</th>
                                    <th>Allowances</th>
                                    <th>Gross Monthly</th>
                                    <th>Statutory Deductions</th>
                                    <th>Loan Deductions</th>
                                    <th>Effective Date</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="configTableBody">
                                <!-- Dynamic content will be loaded here -->
                            </tbody>
                        </table>


                        <!-- Empty State -->
                        <div id="configEmptyState" style="display:none; text-align:center; padding:40px; color:#666;">
                            <div style="font-size:48px;"><svg style="width:48px;height:48px;fill:#999;"
                                    viewBox="0 0 24 24">
                                    <path
                                        d="M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z" />
                                </svg></div>
                            <p style="margin-top:10px;">No payroll configurations found</p>
                            <p style="font-size:14px;">Click "Add New Configuration" to set up employee salaries</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Payroll Generation Tab -->
            <div id="payroll-gen" class="tab-content active">
                <div class="stepper-container">
                    <div class="stepper">
                        <div class="step active" id="step1Indicator">
                            <div class="step-circle">1</div>
                            <div class="step-label">Period</div>
                            <div class="step-line"></div>
                        </div>
                        <div class="step" id="step2Indicator">
                            <div class="step-circle">2</div>
                            <div class="step-label">Employee</div>
                            <div class="step-line"></div>
                        </div>
                        <div class="step" id="step3Indicator">
                            <div class="step-circle">3</div>
                            <div class="step-label">Compute</div>
                            <div class="step-line"></div>
                        </div>
                        <div class="step" id="step4Indicator">
                            <div class="step-circle">4</div>
                            <div class="step-label">Finance</div>
                        </div>
                    </div>
                </div>
                <div class="main-content">
                    <!-- Step 1: Period -->
                    <div class="step-content active" id="step1">
                        <h2 class="step-title">Step 1: Payroll Period Setup</h2>
                        <div class="form-group">
                            <label class="form-label">Payroll Type</label>
                            <asp:DropDownList ID="ddlPayrollType" runat="server" CssClass="form-control"
                                onchange="updateDates(this.value)">
                                <asp:ListItem Value="semi-monthly" Selected="True">Semi-Monthly</asp:ListItem>
                                <asp:ListItem Value="monthly">Monthly</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label">Start Date</label>
                                <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" CssClass="form-control"
                                    Text="2025-01-01"></asp:TextBox>
                            </div>
                            <div class="form-group">
                                <label class="form-label">End Date</label>
                                <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" CssClass="form-control"
                                    Text="2025-01-15"></asp:TextBox>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Cut-off Date</label>
                            <asp:TextBox ID="txtCutoffDate" runat="server" TextMode="Date" CssClass="form-control"
                                Text="2025-01-15"></asp:TextBox>
                        </div>
                        <div class="button-container">
                            <button type="button" class="btn btn-primary" onclick="nextStep(2)">
                                Next: Select Employees
                                <span class="btn-icon">→</span>
                            </button>
                        </div>
                    </div>
                    <!-- Step 2: Employee Selection -->
                    <div class="step-content" id="step2">
                        <h2 class="step-title">Step 2: Employee Selection</h2>
                        <div class="search-filter-container">
                            <div class="search-box">
                                <span class="search-icon"><svg class="svg-icon" viewBox="0 0 24 24" fill="none"
                                        stroke="currentColor" stroke-width="2">
                                        <circle cx="11" cy="11" r="8" />
                                        <path d="m21 21-4.35-4.35" />
                                    </svg></span>
                                <input type="text" class="search-input" placeholder="Search employees..."
                                    id="searchEmployees">
                            </div>
                            <select id="filterDept" class="filter-select">
                                <option value="">All Departments</option>
                                <option value="IT">IT</option>
                                <option value="HR">HR</option>
                                <option value="Finance">Finance</option>
                            </select>
                            <select id="filterRole" class="filter-select">
                                <option value="">All Roles</option>
                                <option value="Developer">Developer</option>
                                <option value="HR Manager">HR Manager</option>
                                <option value="Accountant">Accountant</option>
                            </select>
                        </div>
                        <div class="select-all-container">
                            <label class="checkbox-label">
                                <input type="checkbox" class="checkbox" id="selectAll" checked
                                    onchange="toggleSelectAll()">
                                Select All (<span id="employeeCount">0</span> employees)
                            </label>
                        </div>
                        <!-- Loading State -->
                        <div id="employeeLoadingState" style="text-align:center; padding:40px;">
                            <div style="font-size:48px;">Loading...</div>
                            <p style="color:#666; margin-top:10px;">Loading employees from database...</p>
                        </div>

                        <!-- Error State -->
                        <div id="employeeErrorState"
                            style="display:none; text-align:center; padding:40px; background:#FEE2E2; border-radius:12px;">
                            <div style="font-size:48px;">Error</div>
                            <p style="color:#991B1B; margin-top:10px; font-weight:600;">Failed to load employees</p>
                            <p id="employeeErrorMessage" style="color:#666; font-size:14px;"></p>
                            <button type="button" class="btn btn-primary" onclick="loadEmployees()"
                                style="margin-top:20px;">
                                Retry
                            </button>
                        </div>

                        <!-- Dynamic Employee List - Will be populated by JavaScript -->
                        <div id="employeeList"></div>

                        <div class="button-container">
                            <button type="button" class="btn btn-secondary" onclick="prevStep(1)">Back</button>
                            <button type="button" class="btn btn-primary" onclick="generatePayroll(); return false;">
                                Generate Payroll
                                <span class="btn-icon">→</span>
                            </button>
                        </div>
                    </div>
                    <!-- Step 3: Computation -->
                    <div class="step-content" id="step3">
                        <h2 class="step-title">Step 3: Automatic Salary Computation</h2>

                        <!-- Loading State -->
                        <div id="computationLoadingState" style="text-align:center; padding:40px; display:none;">
                            <div style="font-size:48px;">Computing...</div>
                            <p style="color:#666; margin-top:10px;">Computing payroll for selected employees...</p>
                        </div>

                        <!-- Error State -->
                        <div id="computationErrorState"
                            style="display:none; text-align:center; padding:40px; background:#FEE2E2; border-radius:12px;">
                            <div style="font-size:48px;">Error</div>
                            <p style="color:#991B1B; margin-top:10px; font-weight:600;">Failed to compute payroll</p>
                            <p id="computationErrorMessage" style="color:#666; font-size:14px;"></p>
                            <button type="button" class="btn btn-primary" onclick="prevStep(2)"
                                style="margin-top:20px;">
                                Back to Employee Selection
                            </button>
                        </div>

                        <!-- Dynamic Computation Results Container -->
                        <div id="computationResultsContainer">
                            <!-- Status message will be inserted here -->
                            <div class="computation-status" id="computationStatusMessage" style="display:none;">
                                Computed for <span id="computedCount">0</span> employees. Earnings calculated;
                                deductions to be added by Finance.
                            </div>

                            <!-- Employee computation cards will be dynamically inserted here -->
                            <div id="employeeComputationsContainer"></div>
                        </div>

                        <div class="button-container" id="step3Buttons" style="display:none;">
                            <button type="button" class="btn btn-secondary" onclick="prevStep(2)">Back</button>
                            <button type="button" class="btn btn-primary"
                                onclick="sendToFinanceFromStep3(); return false;">
                                Send to Finance
                                <span class="btn-icon">→</span>
                            </button>
                        </div>
                    </div>

                    <!-- Step 4: Finance / Payment Release -->
                    <div class="step-content" id="step4">
                        <h2 class="step-title">Step 4: Finance - Payment Release</h2>
                        <p style="color:#666; margin-bottom:30px;">Review approved payrolls and release payments to
                            employees.</p>

                        <!-- Loading State -->
                        <div id="financeLoadingState" style="text-align:center; padding:40px; display:none;">
                            <div style="font-size:48px;">⏳</div>
                            <p style="color:#666; margin-top:10px;">Loading approved payrolls...</p>
                        </div>

                        <!-- Error State -->
                        <div id="financeErrorState"
                            style="display:none; text-align:center; padding:40px; background:#FEE2E2; border-radius:12px;">
                            <div style="font-size:48px;">❌</div>
                            <p style="color:#991B1B; margin-top:10px; font-weight:600;">Failed to load payrolls</p>
                            <p id="financeErrorMessage" style="color:#666; font-size:14px;"></p>
                            <button type="button" class="btn btn-primary" onclick="loadApprovedPayrolls()"
                                style="margin-top:20px;">
                                Retry
                            </button>
                        </div>

                        <!-- Empty State -->
                        <div id="financeEmptyState" style="display:none; text-align:center; padding:40px; color:#666;">
                            <div style="font-size:48px;">📋</div>
                            <p style="margin-top:10px;">No approved payrolls found</p>
                            <p style="font-size:14px;">Approved payrolls will appear here for payment release</p>
                        </div>

                        <!-- Approved Payrolls Table -->
                        <div id="financeTableContainer" style="display:none;">
                            <table class="review-table">
                                <thead>
                                    <tr>
                                        <th>Pay Run Number</th>
                                        <th>Period</th>
                                        <th>Employees</th>
                                        <th>Total Gross</th>
                                        <th>Total Deductions</th>
                                        <th>Total Net</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody id="financeTableBody">
                                    <!-- Dynamic content will be loaded here -->
                                </tbody>
                            </table>
                        </div>

                        <div class="button-container" style="margin-top:30px;">
                            <button type="button" class="btn btn-secondary" onclick="prevStep(3)">Back to
                                Computation</button>
                        </div>
                    </div>
                    <!-- Payslips Tab -->
                    <div id="payslips" class="tab-content">
                        <div class="main-content">
                            <h2 class="step-title">Payslips</h2>
                            <p style="color:#666; margin-bottom:30px;">View approved payroll runs that are ready for
                                payslip generation.</p>

                            <!-- Loading State -->
                            <div id="payslipsLoadingState" style="text-align:center; padding:40px; display:none;">
                                <div style="font-size:48px;">Loading...</div>
                                <p style="color:#666; margin-top:10px;">Loading payslips...</p>
                            </div>

                            <!-- Error State -->
                            <div id="payslipsErrorState"
                                style="text-align:center; padding:40px; display:none; color:#991B1B;">
                                <div style="font-size:48px;">Error</div>
                                <p id="payslipsErrorMessage" style="margin-top:10px;">Failed to load payslips</p>
                                <button type="button" class="btn btn-secondary" onclick="loadPayslips()"
                                    style="margin-top:20px;">Retry</button>
                            </div>

                            <!-- Empty State -->
                            <div id="payslipsEmptyState" style="text-align:center; padding:40px; display:none;">
                                <div style="font-size:48px; color:#9CA3AF;">No Payslips</div>
                                <p style="color:#666; margin-top:10px;">No payslips found. Payslips will appear here
                                    after payroll runs are approved.</p>
                            </div>

                            <!-- Payslips Table Container -->
                            <div id="payslipsTableContainer"
                                style="display:none !important; width:100% !important; overflow-x:auto !important; margin-top:20px !important;">
                                <table
                                    style="width:100% !important; border-collapse:collapse !important; background:white !important; min-width:800px !important;">
                                    <thead>
                                        <tr
                                            style="background:linear-gradient(135deg, #A44F56 0%, #8B3E45 100%) !important; color:white !important;">
                                            <th
                                                style="padding:16px !important; font-weight:700 !important; text-transform:uppercase !important; font-size:12px !important; text-align:left !important; border-bottom:2px solid #8B3E45 !important;">
                                                Pay Run</th>
                                            <th
                                                style="padding:16px !important; font-weight:700 !important; text-transform:uppercase !important; font-size:12px !important; text-align:left !important; border-bottom:2px solid #8B3E45 !important;">
                                                Period</th>
                                            <th
                                                style="padding:16px !important; font-weight:700 !important; text-transform:uppercase !important; font-size:12px !important; text-align:center !important; border-bottom:2px solid #8B3E45 !important;">
                                                Employees</th>
                                            <th
                                                style="padding:16px !important; font-weight:700 !important; text-transform:uppercase !important; font-size:12px !important; text-align:right !important; border-bottom:2px solid #8B3E45 !important;">
                                                Gross</th>
                                            <th
                                                style="padding:16px !important; font-weight:700 !important; text-transform:uppercase !important; font-size:12px !important; text-align:right !important; border-bottom:2px solid #8B3E45 !important;">
                                                Deductions</th>
                                            <th
                                                style="padding:16px !important; font-weight:700 !important; text-transform:uppercase !important; font-size:12px !important; text-align:right !important; border-bottom:2px solid #8B3E45 !important;">
                                                Net</th>
                                            <th
                                                style="padding:16px !important; font-weight:700 !important; text-transform:uppercase !important; font-size:12px !important; text-align:left !important; border-bottom:2px solid #8B3E45 !important;">
                                                Pay Date</th>
                                            <th
                                                style="padding:16px !important; font-weight:700 !important; text-transform:uppercase !important; font-size:12px !important; text-align:center !important; border-bottom:2px solid #8B3E45 !important;">
                                                Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody id="payslipsTableBody" style="background:white !important;">
                                        <!-- Dynamic content will be loaded here -->
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    <!-- History Tab -->
                    <div id="history" class="tab-content" style="display:none; width:100%; min-height:400px;">
                        <div class="main-content" style="width:100%; min-height:400px;">
                            <h2 class="step-title">Payroll History</h2>
                            <div class="search-filter-container">
                                <div class="search-box">
                                    <span class="search-icon"><svg class="svg-icon" viewBox="0 0 24 24" fill="none"
                                            stroke="currentColor" stroke-width="2">
                                            <circle cx="11" cy="11" r="8" />
                                            <path d="m21 21-4.35-4.35" />
                                        </svg></span>
                                    <input type="text" class="search-input" placeholder="Search payroll period...">
                                </div>
                                <select class="filter-select">
                                    <option>All Status</option>
                                    <option>Completed</option>
                                    <option>Cancelled</option>
                                </select>
                                <input type="date" class="filter-select" placeholder="Start">
                                <input type="date" class="filter-select" placeholder="End">
                            </div>
                            <!-- Loading State -->
                            <div id="historyLoadingState" style="text-align:center; padding:40px; display:none;">
                                <div style="font-size:48px;">Loading...</div>
                                <p style="color:#666; margin-top:10px;">Loading payroll history from database...</p>
                            </div>

                            <!-- Error State -->
                            <div id="historyErrorState"
                                style="display:none; text-align:center; padding:40px; background:#FEE2E2; border-radius:12px;">
                                <div style="font-size:48px;">Error</div>
                                <p style="color:#991B1B; margin-top:10px; font-weight:600;">Failed to load payroll
                                    history</p>
                                <p id="historyErrorMessage" style="color:#666; font-size:14px;"></p>
                                <button type="button" class="btn btn-primary" onclick="loadPayrollHistory()"
                                    style="margin-top:20px;">
                                    Retry
                                </button>
                            </div>

                            <!-- Empty State -->
                            <div id="historyEmptyState"
                                style="display:none; text-align:center; padding:40px; color:#666;">
                                <div style="font-size:48px;">
                                    <svg style="width:48px;height:48px;fill:#999;" viewBox="0 0 24 24">
                                        <path
                                            d="M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z" />
                                    </svg>
                                </div>
                                <p style="margin-top:10px;">No payroll history found</p>
                                <p style="font-size:14px;">Payroll runs will appear here after they are generated and
                                    processed</p>
                            </div>

                            <!-- History Table -->
                            <div id="historyTableContainer"
                                style="display:none; position:relative; z-index:10; min-height:200px;">
                                <table class="history-table">
                                    <thead>
                                        <tr>
                                            <th>Period</th>
                                            <th>Employees</th>
                                            <th>Gross</th>
                                            <th>Deductions</th>
                                            <th>Net</th>
                                            <th>Date</th>
                                            <th>By</th>
                                            <th>Status</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody id="historyTableBody">
                                        <!-- Dynamic content will be loaded here -->
                                    </tbody>
                                </table>
                                <div id="historyPagination" style="text-align:center; margin-top:20px; color:#666;">
                                    <!-- Pagination will be loaded here -->
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Modals - Moved outside payroll-container to ensure visibility -->
                <!-- Configuration Modal (NEW - Function 6.1) -->
                <div id="configModal" class="modal"
                    style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.7); z-index:99999; justify-content:center; align-items:center;">
                    <div class="modal-content" style="max-width:900px;">
                        <button type="button" class="close-modal" onclick="closeModal()">&times;</button>
                        <h3 id="configModalTitle"
                            style="text-align:center; color:var(--dark-brown); margin-bottom:20px;">Add Payroll
                            Configuration</h3>

                        <!-- Auto-populate instruction banner -->
                        <div id="autoPopulateInstruction"
                            style="background:linear-gradient(135deg, #DBEAFE 0%, #BFDBFE 100%); padding:15px; border-radius:8px; margin-bottom:20px; border-left:4px solid #3B82F6;">
                            <div style="display:flex; align-items:center; gap:10px;">
                                <span style="font-size:24px;">*</span>
                                <div>
                                    <strong style="color:#1E40AF;">Smart Auto-Fill Enabled!</strong>
                                    <p style="margin:5px 0 0 0; color:#1E3A8A; font-size:13px;">
                                        Select an employee below and the system will automatically populate salary rates
                                        based on their department.
                                        You can review and adjust any values before saving.
                                    </p>
                                </div>
                            </div>
                        </div>

                        <!-- Employee Selection (for create mode) -->
                        <div id="configEmployeeSelect" class="form-group">
                            <label class="form-label">Select Employee *</label>
                            <select id="configEmployeeId" class="form-control" onchange="populateEmployeeDetails()">
                                <option value="">-- Select Employee --</option>
                            </select>
                            <small style="color:#666; margin-top:5px; display:block;">Salary will be auto-calculated
                                based on department when you select an employee</small>
                        </div>

                        <!-- Employee Info Display (for edit mode) -->
                        <div id="configEmployeeInfo"
                            style="display:none; background:#F3F4F6; padding:15px; border-radius:8px; margin-bottom:20px;">
                            <div style="display:grid; grid-template-columns:1fr 1fr 1fr; gap:15px;">
                                <div><strong>Employee:</strong> <span id="displayEmployeeName"></span></div>
                                <div><strong>Emp No.:</strong> <span id="displayEmployeeNumber"></span></div>
                                <div><strong>Department:</strong> <span id="displayDepartment"></span></div>
                            </div>
                        </div>

                        <!-- Tabbed Configuration Sections -->
                        <div style="margin-bottom:20px;">
                            <div
                                style="display:flex; gap:10px; border-bottom:2px solid var(--rose-pink); margin-bottom:20px;">
                                <button type="button" class="config-tab-btn active" data-section="salary"
                                    onclick="switchConfigSection('salary')">6.1.1 Salary & Allowances</button>
                                <button type="button" class="config-tab-btn" data-section="deductions"
                                    onclick="switchConfigSection('deductions')">6.1.2 Deductions</button>
                                <button type="button" class="config-tab-btn" data-section="overtime"
                                    onclick="switchConfigSection('overtime')">Overtime Rates</button>
                            </div>

                            <!-- Section 6.1.1: Salary & Allowances -->
                            <div id="config-section-salary" class="config-section">
                                <h4 style="color:var(--primary-burgundy); margin-bottom:15px;">Salary Components</h4>
                                <div class="form-row">
                                    <div class="form-group">
                                        <label class="form-label">Basic Salary (Monthly) *</label>
                                        <input type="number" step="0.01" id="configBasicSalary" class="form-control"
                                            placeholder="25000.00" onchange="calculateTotals()">
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">Housing Allowance</label>
                                        <input type="number" step="0.01" id="configHousingAllowance"
                                            class="form-control" placeholder="5000.00" onchange="calculateTotals()">
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="form-group">
                                        <label class="form-label">Transport Allowance</label>
                                        <input type="number" step="0.01" id="configTransportAllowance"
                                            class="form-control" placeholder="2000.00" onchange="calculateTotals()">
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">Meal Allowance</label>
                                        <input type="number" step="0.01" id="configMealAllowance" class="form-control"
                                            placeholder="1500.00" onchange="calculateTotals()">
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Other Allowances</label>
                                    <input type="number" step="0.01" id="configOtherAllowances" class="form-control"
                                        placeholder="1000.00" onchange="calculateTotals()">
                                </div>

                                <!-- Summary Box -->
                                <div
                                    style="background:linear-gradient(135deg, var(--light-pink) 0%, var(--rose-pink) 100%); padding:15px; border-radius:8px; margin-top:15px;">
                                    <div style="display:flex; justify-content:space-between; margin-bottom:8px;">
                                        <span style="font-weight:600;">Total Allowances:</span>
                                        <span id="totalAllowancesDisplay"
                                            style="font-weight:700; color:var(--primary-burgundy);">₱0.00</span>
                                    </div>
                                    <div style="display:flex; justify-content:space-between;">
                                        <span style="font-weight:700; font-size:16px;">Gross Monthly Salary:</span>
                                        <span id="grossMonthlySalaryDisplay"
                                            style="font-weight:700; font-size:18px; color:var(--primary-burgundy);">₱0.00</span>
                                    </div>
                                </div>
                            </div>

                            <!-- Section 6.1.2: Deductions -->
                            <div id="config-section-deductions" class="config-section" style="display:none;">
                                <h4 style="color:var(--primary-burgundy); margin-bottom:15px;">Statutory Deductions</h4>
                                <div class="form-row">
                                    <div class="form-group">
                                        <label class="form-label">SSS Contribution</label>
                                        <input type="number" step="0.01" id="configSSSContribution" class="form-control"
                                            placeholder="1500.00" onchange="calculateTotals()">
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">PhilHealth Contribution</label>
                                        <input type="number" step="0.01" id="configPhilHealthContribution"
                                            class="form-control" placeholder="900.00" onchange="calculateTotals()">
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="form-group">
                                        <label class="form-label">Pag-IBIG Contribution</label>
                                        <input type="number" step="0.01" id="configPagIbigContribution"
                                            class="form-control" placeholder="100.00" onchange="calculateTotals()">
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">Withholding Tax</label>
                                        <input type="number" step="0.01" id="configWithholdingTax" class="form-control"
                                            placeholder="2000.00" onchange="calculateTotals()">
                                    </div>
                                </div>

                                <h4 style="color:var(--primary-burgundy); margin:20px 0 15px 0;">Loan Deductions</h4>
                                <div class="form-row">
                                    <div class="form-group">
                                        <label class="form-label">SSS Loan</label>
                                        <input type="number" step="0.01" id="configSSSLoan" class="form-control"
                                            placeholder="500.00" onchange="calculateTotals()">
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">Pag-IBIG Loan</label>
                                        <input type="number" step="0.01" id="configPagIbigLoan" class="form-control"
                                            placeholder="300.00" onchange="calculateTotals()">
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="form-group">
                                        <label class="form-label">Company Loan</label>
                                        <input type="number" step="0.01" id="configCompanyLoan" class="form-control"
                                            placeholder="1000.00" onchange="calculateTotals()">
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">Other Deductions</label>
                                        <input type="number" step="0.01" id="configOtherDeductions" class="form-control"
                                            placeholder="0.00" onchange="calculateTotals()">
                                    </div>
                                </div>

                                <h4 style="color:var(--primary-burgundy); margin:20px 0 15px 0;">Penalty Rates</h4>
                                <div class="form-row">
                                    <div class="form-group">
                                        <label class="form-label">Absence Penalty (per day)</label>
                                        <input type="number" step="0.01" id="configAbsencePenaltyRate"
                                            class="form-control" placeholder="1200.00">
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">Late Penalty (per hour)</label>
                                        <input type="number" step="0.01" id="configLatePenaltyRate" class="form-control"
                                            placeholder="150.00">
                                    </div>
                                </div>

                                <!-- Summary Box -->
                                <div
                                    style="background:linear-gradient(135deg, #FEE2E2 0%, #FECACA 100%); padding:15px; border-radius:8px; margin-top:15px;">
                                    <div style="display:flex; justify-content:space-between; margin-bottom:8px;">
                                        <span style="font-weight:600;">Total Statutory Deductions:</span>
                                        <span id="totalStatutoryDeductionsDisplay"
                                            style="font-weight:700; color:#991B1B;">₱0.00</span>
                                    </div>
                                    <div style="display:flex; justify-content:space-between;">
                                        <span style="font-weight:700; font-size:16px;">Total Loan Deductions:</span>
                                        <span id="totalLoanDeductionsDisplay"
                                            style="font-weight:700; font-size:16px; color:#991B1B;">₱0.00</span>
                                    </div>
                                </div>
                            </div>

                            <!-- Section: Overtime Rates -->
                            <div id="config-section-overtime" class="config-section" style="display:none;">
                                <h4 style="color:var(--primary-burgundy); margin-bottom:15px;">Overtime Rates</h4>
                                <div class="form-row">
                                    <div class="form-group">
                                        <label class="form-label">Regular Overtime Rate (per hour)</label>
                                        <input type="number" step="0.01" id="configRegularOvertimeRate"
                                            class="form-control" placeholder="250.00">
                                        <small style="color:#666;">Standard overtime rate for regular working
                                            days</small>
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">Holiday Overtime Rate (per hour)</label>
                                        <input type="number" step="0.01" id="configHolidayOvertimeRate"
                                            class="form-control" placeholder="500.00">
                                        <small style="color:#666;">Premium rate for holidays and rest days</small>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Night Differential Rate (per hour)</label>
                                    <input type="number" step="0.01" id="configNightDifferentialRate"
                                        class="form-control" placeholder="50.00">
                                    <small style="color:#666;">Additional rate for night shift (10PM - 6AM)</small>
                                </div>
                            </div>
                        </div>

                        <!-- Metadata -->
                        <div class="form-group">
                            <label class="form-label">Effective Date *</label>
                            <input type="date" id="configEffectiveDate" class="form-control">
                        </div>

                        <!-- Save Actions -->
                        <div class="button-container">
                            <button type="button" class="btn btn-secondary" onclick="closeModal()">Cancel</button>
                            <button type="button" class="btn btn-primary" onclick="savePayrollConfiguration()">
                                Save Configuration
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Existing modals -->
                <div id="payslipModal" class="modal">
                    <div class="modal-content">
                        <button type="button" class="close-modal" onclick="closeModal()">&times;</button>
                        <h3 style="text-align:center; color:var(--dark-brown);">PAYSLIP</h3>
                        <div style="text-align:center; margin-bottom:20px; color:#666;" id="payslipPeriod">Jan 1–15,
                            2025</div>
                        <div style="display:grid; grid-template-columns:1fr 1fr; gap:20px; margin-bottom:20px;"
                            id="payslipEmpInfo">
                            <div><strong>Employee:</strong> Juan Dela Cruz</div>
                            <div><strong>Emp No.:</strong> EMP001</div>
                            <div><strong>Department:</strong> IT</div>
                            <div><strong>Position:</strong> Developer</div>
                        </div>
                        <table style="width:100%; border-collapse:collapse; margin-bottom:20px;">
                            <thead>
                                <tr style="background:var(--light-pink);">
                                    <th style="padding:10px; text-align:left;">Earnings</th>
                                    <th style="padding:10px;">Amount</th>
                                    <th style="padding:10px; text-align:left;">Deductions</th>
                                    <th style="padding:10px;">Amount</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>Basic Salary</td>
                                    <td>&#8369;50,000.00</td>
                                    <td>SSS</td>
                                    <td>&#8369;1,960.00</td>
                                </tr>
                                <tr>
                                    <td>Allowances</td>
                                    <td>&#8369;2,666.66</td>
                                    <td>PhilHealth</td>
                                    <td>&#8369;900.00</td>
                                </tr>
                                <tr>
                                    <td>Overtime</td>
                                    <td>&#8369;500.00</td>
                                    <td>Pag-IBIG</td>
                                    <td>&#8369;100.00</td>
                                </tr>
                                <tr>
                                    <td>Bonus</td>
                                    <td>&#8369;2,000.00</td>
                                    <td>Tax</td>
                                    <td>&#8369;2,000.00</td>
                                </tr>
                                <tr>
                                    <td></td>
                                    <td></td>
                                    <td>Loan</td>
                                    <td>&#8369;240.00</td>
                                </tr>
                                <tr style="border-top:2px solid var(--primary-burgundy);">
                                    <td><strong>Total</strong></td>
                                    <td><strong id="modalGross">&#8369;55,166.66</strong></td>
                                    <td><strong>Total</td>
                                    <td><strong id="modalDeductions">&#8369;5,200.00</strong></td>
                                </tr>
                            </tbody>
                        </table>
                        <div style="text-align:center; font-size:20px, 18px; font-weight:bold; color:var(--primary-burgundy);"
                            id="modalNet">
                            NET SALARY: &#8369;50,000.00
                        </div>
                        <div style="margin-top:30px; text-align:center; font-size:13px; color:#888;">
                            Authorized by: HR Manager & Finance Officer | Company Stamp
                        </div>
                    </div>
                </div>

                <div id="summaryModal" class="modal">
                    <div class="modal-content">
                        <button type="button" class="close-modal" onclick="closeModal()">&times;</button>
                        <h4><svg class="svg-icon" viewBox="0 0 24 24" fill="currentColor"
                                style="margin-right: 8px; vertical-align: middle;">
                                <path
                                    d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z" />
                            </svg> Summarize Salary Computation</h4>
                        <div style="margin-top:20px;">
                            <div class="form-group">
                                <label class="form-label">From</label>
                                <input type="date" class="form-control" value="2025-01-01" />
                            </div>
                            <div class="form-group">
                                <label class="form-label">To</label>
                                <input type="date" class="form-control" value="2025-01-31" />
                            </div>
                            <div class="button-container">
                                <button type="button" class="btn btn-secondary" onclick="closeModal()">Cancel</button>
                                <button type="button" class="btn btn-primary"
                                    onclick="alert('Summary for selected range generated.')">Show Summary</button>
                            </div>
                        </div>
                    </div>
                </div>

                <script>
                    // PAYROLL.ASPX v2.0.20251202.0100 - CRITICAL FIX: Tab Navigation
                    // 🎯 Global Variables
                    var __currentPayRun = null; // Stores current payroll generation data

                    // Note: switchTab function is now defined in the <head> section for immediate availability

                    function nextStep(stepNumber) {
                        console.log('[nextStep] Moving to Step', stepNumber);

                        // Update step indicators and content
                        document.querySelectorAll('.step-content').forEach(el => el.classList.remove('active'));
                        document.querySelectorAll('.step').forEach(el => { el.classList.remove('active'); el.classList.remove('completed'); });
                        document.getElementById('step' + stepNumber).classList.add('active');

                        // Mark previous steps as completed
                        for (let i = 1; i < stepNumber; i++) {
                            document.getElementById('step' + i + 'Indicator').classList.add('completed');
                        }
                        document.getElementById('step' + stepNumber + 'Indicator').classList.add('active');

                        // 🎯 DYNAMIC STEP 4: Populate review table when entering Step 4
                        if (stepNumber === 4) {
                            populateStep4ReviewTable();
                        }

                        // Special handling for Step 2 (lazy load employees)
                        if (stepNumber === 2) {
                            loadEmployees();
                        }

                        window.scrollTo({ top: 0, behavior: 'smooth' });
                        updateDashboard();
                    }

                    function prevStep(stepNumber) {
                        nextStep(stepNumber);
                    }

                    /**
                     * 🎯 NEW: Populate Step 4 review table with dynamic data from Step 3
                     */
                    function populateStep4ReviewTable() {
                        console.log('🎨 Populating Step 4 review table...');

                        const loadingState = document.getElementById('step4LoadingState');
                        const errorState = document.getElementById('step4ErrorState');
                        const contentArea = document.getElementById('step4ContentArea');
                        const tableBody = document.getElementById('step4TableBody');

                        // Show loading initially
                        loadingState.style.display = 'block';
                        errorState.style.display = 'none';
                        contentArea.style.display = 'none';

                        // Check if we have payroll data from Step 3
                        if (!__currentPayRun || !__currentPayRun.items || __currentPayRun.items.length === 0) {
                            console.log('❌ No payroll data available for Step 4');
                            setTimeout(() => {
                                loadingState.style.display = 'none';
                                errorState.style.display = 'block';
                            }, 500);
                            return;
                        }

                        console.log('✅ Found payroll data:', __currentPayRun.items.length, 'employees');

                        // Clear existing table content
                        tableBody.innerHTML = '';

                        let totalGross = 0;
                        let totalDeductions = 0;
                        let totalNet = 0;

                        // Populate table with computed payroll data
                        __currentPayRun.items.forEach((item, index) => {
                            const row = document.createElement('tr');

                            // Calculate values
                            const gross = item.grossSalary || 0;
                            const deductions = item.totalDeductions || 0;
                            const net = item.netSalary || 0;

                            // Update totals
                            totalGross += gross;
                            totalDeductions += deductions;
                            totalNet += net;

                            row.innerHTML = `
                <td>${item.employeeNumber || 'EMP' + (index + 1).toString().padStart(3, '0')}</td>
                <td>${item.employeeName || 'N/A'}</td>
                <td>${item.department || 'N/A'}</td>
                <td>${item.daysPresent || 0}</td>
                <td class="amount-green editable-cell" data-value="${gross}" data-employee-id="${item.employeeId}">
                    &#8369;${gross.toLocaleString('en-PH', { minimumFractionDigits: 2 })}
                    <input type="number" step="0.01" value="${gross}" onchange="updateGrossInReview(this)" style="display:none;" />
                </td>
                <td class="amount-gray">&#8369;${deductions.toLocaleString('en-PH', { minimumFractionDigits: 2 })}</td>
                <td class="amount-blue">&#8369;${net.toLocaleString('en-PH', { minimumFractionDigits: 2 })}</td>
                <td class="remarks-cell" contenteditable="true" data-employee-id="${item.employeeId}">${item.remarks || '(Optional)'}</td>
                <td>
                    <span class="edit-icon" onclick="toggleEditGross(this)" title="Edit Gross Salary">
                        <svg class="svg-icon-sm" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/>
                        </svg>
                    </span>
                </td>
            `;

                            tableBody.appendChild(row);
                        });

                        // Add total row
                        const totalRow = document.createElement('tr');
                        totalRow.className = 'total-row-table';
                        totalRow.innerHTML = `
            <td colspan="4"><strong>TOTAL:</strong></td>
            <td class="amount-green" id="totalGrossReview"><strong>&#8369;${totalGross.toLocaleString('en-PH', { minimumFractionDigits: 2 })}</strong></td>
            <td class="amount-gray"><strong>&#8369;${totalDeductions.toLocaleString('en-PH', { minimumFractionDigits: 2 })}</strong></td>
            <td class="amount-blue" id="totalNetReview"><strong>&#8369;${totalNet.toLocaleString('en-PH', { minimumFractionDigits: 2 })}</strong></td>
            <td></td>
            <td></td>
        `;
                        tableBody.appendChild(totalRow);

                        // Show content, hide loading
                        setTimeout(() => {
                            loadingState.style.display = 'none';
                            contentArea.style.display = 'block';
                            console.log('✅ Step 4 review table populated successfully');
                        }, 800); // Small delay for smooth transition
                    }

                    /**
                     * 🎯 NEW: Toggle edit mode for gross salary in review table
                     */
                    function toggleEditGross(editIcon) {
                        const cell = editIcon.closest('tr').querySelector('.editable-cell');
                        const input = cell.querySelector('input');

                        if (input.style.display === 'none') {
                            // Enter edit mode
                            input.style.display = 'inline-block';
                            input.focus();
                            input.select();
                            editIcon.innerHTML = '<svg class="svg-icon-sm" viewBox="0 0 24 24" fill="currentColor"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>';
                            editIcon.title = 'Save Changes';
                        } else {
                            // Save changes
                            updateGrossInReview(input);
                            input.style.display = 'none';
                            editIcon.innerHTML = '<svg class="svg-icon-sm" viewBox="0 0 24 24" fill="currentColor"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg>';
                            editIcon.title = 'Edit Gross Salary';
                        }
                    }

                    /**
                     * 🎯 NEW: Update gross salary in review table and recalculate totals
                     */
                    function updateGrossInReview(input) {
                        const newValue = parseFloat(input.value) || 0;
                        const cell = input.parentElement;
                        const employeeId = cell.getAttribute('data-employee-id');

                        console.log('💰 Updating gross salary for employee', employeeId, 'to', newValue);

                        // Update display
                        const formattedValue = '&#8369;' + newValue.toLocaleString('en-PH', { minimumFractionDigits: 2 });
                        const textContent = cell.childNodes[0];
                        if (textContent) textContent.textContent = formattedValue;

                        // Update data attribute
                        cell.setAttribute('data-value', newValue);

                        // Mark as edited
                        cell.classList.add('edited');
                        cell.style.backgroundColor = '#FFF3CD'; // Light yellow highlight

                        // Update the payroll data in memory
                        if (__currentPayRun && __currentPayRun.items) {
                            const item = __currentPayRun.items.find(i => i.employeeId === employeeId);
                            if (item) {
                                const oldGross = item.grossSalary || 0;
                                item.grossSalary = newValue;
                                // Recalculate net (gross - deductions)
                                item.netSalary = newValue - (item.totalDeductions || 0);

                                console.log('📊 Updated employee data:', {
                                    name: item.employeeName,
                                    oldGross: oldGross,
                                    newGross: newValue,
                                    deductions: item.totalDeductions,
                                    newNet: item.netSalary
                                });

                                // Update net salary in the same row
                                const netCell = cell.closest('tr').querySelector('.amount-blue');
                                if (netCell) {
                                    netCell.textContent = '&#8369;' + item.netSalary.toLocaleString('en-PH', { minimumFractionDigits: 2 });
                                }
                            }
                        }

                        // Recalculate totals
                        recalculateReviewTotals();
                    }

                    /**
                     * 🎯 NEW: Recalculate totals in review table
                     */
                    function recalculateReviewTotals() {
                        let totalGross = 0;
                        let totalNet = 0;

                        // Sum up all gross values
                        document.querySelectorAll('#step4TableBody .editable-cell[data-value]').forEach(cell => {
                            totalGross += parseFloat(cell.getAttribute('data-value')) || 0;
                        });

                        // Sum up all net values (from the payroll data)
                        if (__currentPayRun && __currentPayRun.items) {
                            totalNet = __currentPayRun.items.reduce((sum, item) => sum + (item.netSalary || 0), 0);
                        }

                        // Update total displays
                        const totalGrossEl = document.getElementById('totalGrossReview');
                        const totalNetEl = document.getElementById('totalNetReview');

                        if (totalGrossEl) {
                            totalGrossEl.innerHTML = '<strong>&#8369;' + totalGross.toLocaleString('en-PH', { minimumFractionDigits: 2 }) + '</strong>';
                        }
                        if (totalNetEl) {
                            totalNetEl.innerHTML = '<strong>&#8369;' + totalNet.toLocaleString('en-PH', { minimumFractionDigits: 2 }) + '</strong>';
                        }

                        // Update dashboard stats
                        if (__currentPayRun) {
                            __currentPayRun.totalGross = totalGross;
                            __currentPayRun.totalNet = totalNet;
                            updateDashboard();
                        }

                        console.log('🧮 Totals recalculated:', {
                            totalGross: totalGross,
                            totalNet: totalNet
                        });
                    }

                    // 🎯 CRITICAL FIXES: Add missing functions that are called but not defined

                    /**
                     * Update dashboard statistics (called by nextStep and other functions)
                     */
                    function updateDashboard() {
                        console.log('📊 updateDashboard() called');

                        // Check if we have payroll data
                        if (typeof __currentPayRun === 'undefined' || !__currentPayRun) {
                            console.log('⚠️ No payroll data available for dashboard update');
                            return;
                        }

                        // Update period display
                        const periodEl = document.getElementById('statPeriod');
                        if (periodEl && __currentPayRun.period) {
                            periodEl.textContent = __currentPayRun.period;
                        }

                        // Update employee count
                        const employeesEl = document.getElementById('statEmployees');
                        if (employeesEl) {
                            const count = __currentPayRun.items ? __currentPayRun.items.length : 0;
                            employeesEl.textContent = count;
                        }

                        // Update total gross
                        const grossEl = document.getElementById('statGross');
                        if (grossEl && __currentPayRun.totalGross) {
                            grossEl.textContent = '&#8369;' + __currentPayRun.totalGross.toLocaleString('en-PH', { minimumFractionDigits: 2 });
                        }

                        // Update status
                        const statusEl = document.getElementById('statStatus');
                        if (statusEl && __currentPayRun.status) {
                            statusEl.textContent = __currentPayRun.status;
                        }

                        console.log('✅ Dashboard updated:', __currentPayRun);
                    }

                    /**
                     * Generate Payroll - Main computation function (called by Step 2 button)
                     * This function is defined in generatePayroll-fixed.js but we provide a fallback
                     */
                    if (typeof generatePayroll === 'undefined') {
                        console.warn('⚠️ generatePayroll() not loaded from external file, using fallback');

                        function generatePayroll() {
                            console.log('🚀 generatePayroll() called (fallback implementation)');

                            // Show loading in Step 3
                            const loadingState = document.getElementById('computationLoadingState');
                            const errorState = document.getElementById('computationErrorState');
                            const resultsContainer = document.getElementById('computationResultsContainer');

                            if (loadingState) loadingState.style.display = 'block';
                            if (errorState) errorState.style.display = 'none';
                            if (resultsContainer) resultsContainer.style.display = 'none';

                            // Move to Step 3
                            nextStep(3);

                            // Get selected employees
                            const selectedEmployees = [];
                            document.querySelectorAll('.employee-card').forEach(card => {
                                const checkbox = card.querySelector('input[type="checkbox"]');
                                if (checkbox && checkbox.checked) {
                                    const empId = checkbox.getAttribute('data-employee-id');
                                    const empName = checkbox.getAttribute('data-employee-name');
                                    const empNumber = checkbox.getAttribute('data-employee-number');
                                    const empDept = checkbox.getAttribute('data-employee-dept');

                                    selectedEmployees.push({
                                        id: empId,
                                        name: empName,
                                        number: empNumber,
                                        department: empDept
                                    });
                                }
                            });

                            console.log('📋 Selected employees:', selectedEmployees.length);

                            if (selectedEmployees.length === 0) {
                                if (errorState) {
                                    errorState.style.display = 'block';
                                    const errorMsg = document.getElementById('computationErrorMessage');
                                    if (errorMsg) errorMsg.textContent = 'No employees selected. Please go back and select employees.';
                                }
                                if (loadingState) loadingState.style.display = 'none';
                                return;
                            }

                            // Call server-side computation
                            $.ajax({
                                type: 'POST',
                                url: 'Payroll.aspx/GeneratePayroll',
                                contentType: 'application/json; charset=utf-8',
                                dataType: 'json',
                                data: JSON.stringify({
                                    startDate: document.getElementById('<%=txtStartDate.ClientID%>').value,
                                    endDate: document.getElementById('<%=txtEndDate.ClientID%>').value,
                                    cutoffDate: document.getElementById('<%=txtCutoffDate.ClientID%>').value,
                                    employeeIds: selectedEmployees.map(e => e.id)
                                }),
                                success: function (response) {
                                    console.log('✅ Server response:', response);

                                    if (loadingState) loadingState.style.display = 'none';

                                    // Parse response
                                    let result = response.d;
                                    if (typeof result === 'string') {
                                        result = JSON.parse(result);
                                    }

                                    if (result.success && result.payRun) {
                                        // Store globally
                                        window.__currentPayRun = result.payRun;

                                        // Show computation results
                                        displayComputationResults(result.payRun);
                                        updateDashboard();
                                    } else {
                                        if (errorState) {
                                            errorState.style.display = 'block';
                                            const errorMsg = document.getElementById('computationErrorMessage');
                                            if (errorMsg) errorMsg.textContent = result.message || 'Failed to generate payroll';
                                        }
                                    }
                                },
                                error: function (xhr, status, error) {
                                    console.error('❌ AJAX Error:', error);
                                    if (loadingState) loadingState.style.display = 'none';
                                    if (errorState) {
                                        errorState.style.display = 'block';
                                        const errorMsg = document.getElementById('computationErrorMessage');
                                        if (errorMsg) errorMsg.textContent = 'Server error: ' + error;
                                    }
                                }
                            });
                        }
                    }

                    /**
                     * Display computation results in Step 3
                     */
                    function displayComputationResults(payRun) {
                        console.log('📊 Displaying computation results...');

                        const statusMessage = document.getElementById('computationStatusMessage');
                        const countSpan = document.getElementById('computedCount');
                        const container = document.getElementById('employeeComputationsContainer');
                        const buttons = document.getElementById('step3Buttons');

                        if (statusMessage) statusMessage.style.display = 'block';
                        if (countSpan) countSpan.textContent = payRun.items ? payRun.items.length : 0;
                        if (buttons) buttons.style.display = 'flex';

                        if (!container || !payRun.items) return;

                        container.innerHTML = '';

                        payRun.items.forEach(item => {
                            const card = document.createElement('div');
                            card.className = 'employee-computation';
                            card.innerHTML = `
                <div class="computation-header">
                    <div class="employee-name">${item.employeeName || 'N/A'}</div>
                    <span class="status-badge">Computed</span>
                </div>
                <div class="computation-grid">
                    <div class="computation-section">
                        <div class="section-title">Earnings</div>
                        <div class="computation-item">
                            <span class="item-label">Basic Salary</span>
                            <span class="item-value">\u20B1${(item.basicSalary || 0).toLocaleString('en-PH', { minimumFractionDigits: 2 })}</span>
                        </div>
                        <div class="computation-item">
                            <span class="item-label">Allowances</span>
                            <span class="item-value">\u20B1${(item.totalAllowances || 0).toLocaleString('en-PH', { minimumFractionDigits: 2 })}</span>
                        </div>
                        <div class="computation-item total-row">
                            <span class="item-label">Gross Salary</span>
                            <span class="item-value">\u20B1${(item.grossSalary || 0).toLocaleString('en-PH', { minimumFractionDigits: 2 })}</span>
                        </div>
                    </div>
                    <div class="computation-section">
                        <div class="section-title">Deductions</div>
                        <div class="computation-item">
                            <span class="item-label">SSS</span>
                            <span class="item-value">\u20B1${(item.sssContribution || 0).toLocaleString('en-PH', { minimumFractionDigits: 2 })}</span>
                        </div>
                        <div class="computation-item">
                            <span class="item-label">PhilHealth</span>
                            <span class="item-value">\u20B1${(item.philHealthContribution || 0).toLocaleString('en-PH', { minimumFractionDigits: 2 })}</span>
                        </div>
                        <div class="computation-item">
                            <span class="item-label">Pag-IBIG</span>
                            <span class="item-value">\u20B1${(item.pagIbigContribution || 0).toLocaleString('en-PH', { minimumFractionDigits: 2 })}</span>
                        </div>
                        <div class="computation-item total-row">
                            <span class="item-label">Total Deductions</span>
                            <span class="item-value">\u20B1${(item.totalDeductions || 0).toLocaleString('en-PH', { minimumFractionDigits: 2 })}</span>
                        </div>
                    </div>
                </div>
                <div class="net-salary-box">
                    <div class="net-salary-label">Net Salary</div>
                    <div class="net-salary-value">\u20B1${(item.netSalary || 0).toLocaleString('en-PH', { minimumFractionDigits: 2 })}</div>
                </div>
            `;
                            container.appendChild(card);
                        });

                        console.log('✅ Computation results displayed');
                    }

                    // Note: viewPayrollHistory, displayPayrollDetails, and closePayrollDetailsModal functions are now defined in the <head> section for immediate availability

                    /**
                     * Download payroll history
                     */
                    function downloadPayrollHistory(payRunId) {
                        console.log('[downloadPayrollHistory] Downloading pay run:', payRunId);
                        // TODO: Implement download functionality
                        alert('Download payroll for: ' + payRunId);
                    }

                    // Note: loadPayslips, viewPayslip, and downloadPayslip functions are now defined in the <head> section for immediate availability

                    // Auto-load history when page is ready (if history tab is active)
                    $(document).ready(function () {
                        console.log('[Payroll.aspx] Document ready');

                        // Check if history tab is currently active
                        var historyTab = document.getElementById('history');
                        if (historyTab && historyTab.classList.contains('active')) {
                            console.log('[Payroll.aspx] History tab is active, loading data...');
                            setTimeout(function () {
                                loadPayrollHistory();
                            }, 500);
                        }
                    });
                </script>

                <!-- Payroll Details Modal -->
                <div id="payrollDetailsModal" class="modal"
                    style="display:none !important; position:fixed !important; top:0 !important; left:0 !important; width:100% !important; height:100% !important; background:rgba(0,0,0,0.5) !important; z-index:9999 !important; justify-content:center !important; align-items:center !important;">
                    <div class="modal-content"
                        style="background:white !important; width:90% !important; max-width:1200px !important; max-height:90vh !important; border-radius:16px !important; padding:30px !important; position:relative !important; overflow:hidden !important; box-shadow:0 10px 40px rgba(0,0,0,0.3) !important;">
                        <button type="button" class="close-modal" onclick="closePayrollDetailsModal()"
                            style="position:absolute !important; top:15px !important; right:15px !important; font-size:28px !important; cursor:pointer !important; background:none !important; border:none !important; color:#666 !important; z-index:10000 !important;">&times;</button>
                        <div id="payrollDetailsContent" style="padding-top:20px !important;">
                            <!-- Content will be populated by JavaScript -->
                        </div>
                    </div>
                </div>
    </asp:Content>