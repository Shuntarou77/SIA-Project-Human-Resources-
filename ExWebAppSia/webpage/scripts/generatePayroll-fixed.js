// ========================================
// PAYROLL GENERATION - Generate Payroll Button Handler
// Version: 3.0 (2025-02-01) - Using async handler
// Purpose: Handle "Generate Payroll" button click in Step 2
// ========================================

// Global variable to store current pay run data
let __currentPayRun = null;

/**
 * ?? Main function - Generate Payroll
 * Called when user clicks "Generate Payroll" button in Step 2
 */
function generatePayroll() {
    console.log('========================================');
    console.log('?? generatePayroll() - START (v3.0)');
    console.log('========================================');

    // Get selected employee IDs from checkboxes
    const checkboxes = document.querySelectorAll('#employeeList .employee-checkbox:checked');
    console.log(`Found ${checkboxes.length} checked checkboxes`);

    // Extract employee IDs (use data-employee-id attribute, NOT value)
    const employeeIds = Array.from(checkboxes)
        .map(checkbox => checkbox.getAttribute('data-employee-id'))
        .filter(id => id && id.trim() !== '');

    console.log('Selected employee IDs:', employeeIds);

    // Validate selection
    if (employeeIds.length === 0) {
        alert('?? Please select at least one employee to generate payroll');
        console.log('? No employees selected');
        return;
    }

    console.log(`? ${employeeIds.length} employees selected for payroll generation`);

    // Get date range from Step 1
    const startDate = document.querySelector('[id$="txtStartDate"]')?.value || '';
    const endDate = document.querySelector('[id$="txtEndDate"]')?.value || '';

    console.log('Date range:', { startDate, endDate });

    // Validate dates
    if (!startDate || !endDate) {
        alert('?? Please select start and end dates in Step 1');
        console.log('? Missing date range');
        return;
    }

    // Move to Step 3 and show loading
    console.log('?? Moving to Step 3...');
    nextStep(3);

    // Show loading state
    const loadingState = document.getElementById('computationLoadingState');
    const errorState = document.getElementById('computationErrorState');
    const statusMessage = document.getElementById('computationStatusMessage');
    const buttonsContainer = document.getElementById('step3Buttons');
    const computationsContainer = document.getElementById('employeeComputationsContainer');

    if (loadingState) loadingState.style.display = 'block';
    if (errorState) errorState.style.display = 'none';
    if (statusMessage) statusMessage.style.display = 'none';
    if (buttonsContainer) buttonsContainer.style.display = 'none';
    if (computationsContainer) computationsContainer.innerHTML = '';

    console.log('?? Calling GeneratePayrollHandler (async handler)...');
    console.log('?? Request data:', {
        employeeIds: employeeIds,
        startDate: startDate,
        endDate: endDate,
        createdBy: 'HR Admin'
    });

    // ?? NEW: Call async handler instead of WebMethod
    $.ajax({
        type: 'POST',
        url: '../Handler/GeneratePayrollHandler.ashx',  // Changed from /Handler/ to ../Handler/
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        data: JSON.stringify({
            employeeIds: employeeIds,
            startDate: startDate,
            endDate: endDate,
            createdBy: 'HR Admin'
        }),
        timeout: 180000, // 3-minute timeout
        success: function (response) {
            console.log('========================================');
            console.log('? GeneratePayrollHandler - SUCCESS');
            console.log('?? Raw response:', response);
            console.log('========================================');

            try {
                // Response is already parsed JSON (no .d wrapper)
                let result = response;

                console.log('?? Response data:', result);

                // Check for success
                if (!result || result.success !== true) {
                    const errorMsg = result?.message || 'Failed to generate payroll';
                    console.error('? Handler returned error:', errorMsg);
                    throw new Error(errorMsg);
                }

                // Check for data
                if (!result.data) {
                    console.error('? No payroll data in response');
                    throw new Error('No payroll data returned from handler');
                }

                console.log('? Payroll data received:', result.data);

                // Store pay run data globally
                __currentPayRun = result.data;

                // Render payroll computations
                console.log('?? Rendering payroll computations...');
                renderPayrollComputations(result.data.items || []);

                // Update UI
                const computedCount = result.data.totalEmployees || employeeIds.length;
                if (document.getElementById('computedCount')) {
                    document.getElementById('computedCount').textContent = computedCount;
                }

                // Show success message and buttons
                if (statusMessage) statusMessage.style.display = 'block';
                if (buttonsContainer) buttonsContainer.style.display = 'flex';
                if (loadingState) loadingState.style.display = 'none';

                // Update dashboard stats
                updateDashboard();

                console.log('? Payroll generation complete!');
                console.log('========================================');

            } catch (parseError) {
                console.error('========================================');
                console.error('? Error processing response:', parseError);
                console.error('Stack:', parseError.stack);
                console.error('========================================');
                showComputationError('Error processing payroll data: ' + parseError.message);
            }
        },
        error: function (xhr, textStatus, errorThrown) {
            console.error('========================================');
            console.error('? GeneratePayrollHandler - AJAX ERROR');
            console.error('Status:', xhr.status);
            console.error('Status Text:', textStatus);
            console.error('Error:', errorThrown);
            console.error('Response Text:', xhr.responseText ? xhr.responseText.substring(0, 500) : 'N/A');
            console.error('========================================');

            let errorMessage = 'Unknown error occurred';

            if (textStatus === 'timeout') {
                errorMessage = '?? Request timed out after 3 minutes.\n\nThis usually means:\n� MongoDB is slow or unreachable\n� Complex payroll calculations taking too long\n� Network connectivity issues\n\nTry:\n� Select fewer employees\n� Check MongoDB Atlas connection\n� Check server logs for errors';
            } else if (xhr.status === 0) {
                errorMessage = '?? Cannot connect to server.\n\nCheck:\n� Is the application running?\n� Any firewall blocking the request?\n� Network connectivity';
            } else if (xhr.status === 404) {
                errorMessage = '? GeneratePayrollHandler.ashx not found.\n\nSolution:\n� Rebuild the solution\n� Restart the application\n� Check Handler folder exists\n� Check URL: /Handler/GeneratePayrollHandler.ashx';
            } else if (xhr.status === 400 || xhr.status === 503 || xhr.status === 504) {
                // Try to parse error message from response
                try {
                    const errorResponse = JSON.parse(xhr.responseText);
                    errorMessage = errorResponse.message || errorThrown;
                } catch {
                    errorMessage = '? Error: ' + errorThrown + '\n\nStatus Code: ' + xhr.status;
                }
            } else if (xhr.status === 500) {
                // Try to parse server error
                try {
                    const errorResponse = JSON.parse(xhr.responseText);
                    errorMessage = '?? Server error:\n\n' + (errorResponse.message || 'Unknown server error') +
                        '\n\nCheck:\n� Visual Studio Output window\n� MongoDB connection\n� Payroll configurations exist';
                } catch {
                    errorMessage = '?? Server error (500).\n\nCheck:\n� Visual Studio Output window\n� Server logs for detailed error\n� MongoDB connection\n\nResponse:\n' +
                        (xhr.responseText ? xhr.responseText.substring(0, 300) : 'No details available');
                }
            } else {
                errorMessage = '? Error: ' + (errorThrown || textStatus) + '\n\nStatus Code: ' + xhr.status;
            }

            showComputationError(errorMessage);
        }
    });
}

/**
 * ?? Render payroll computations in Step 3
 */
function renderPayrollComputations(items) {
    console.log(`?? Rendering ${items.length} payroll items...`);

    const container = document.getElementById('employeeComputationsContainer');
    if (!container) {
        console.error('? employeeComputationsContainer not found!');
        return;
    }

    container.innerHTML = '';

    if (!items || items.length === 0) {
        container.innerHTML = '<p style="text-align:center;color:#666;padding:40px;">No payroll items to display</p>';
        return;
    }

    items.forEach((item, index) => {
        const card = document.createElement('div');
        card.className = 'employee-computation';
        card.innerHTML = `
            <div class="computation-header">
                <div class="employee-name">${item.employeeName || 'Unknown Employee'}</div>
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
                    <div class="computation-item">
                        <span class="item-label">Overtime</span>
                        <span class="item-value">\u20B1${(item.overtimePay || 0).toLocaleString('en-PH', { minimumFractionDigits: 2 })}</span>
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
                    <div class="computation-item">
                        <span class="item-label">Withholding Tax</span>
                        <span class="item-value">\u20B1${(item.withholdingTax || 0).toLocaleString('en-PH', { minimumFractionDigits: 2 })}</span>
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

        if (index < 3) {
            console.log(`  ? Rendered item ${index + 1}:`, {
                name: item.employeeName,
                gross: item.grossSalary,
                deductions: item.totalDeductions,
                net: item.netSalary
            });
        }
    });

    console.log(`? Rendered ${items.length} payroll computation cards`);
}

/**
 * ? Show computation error
 */
function showComputationError(message) {
    console.error('? Showing computation error:', message);

    const loadingState = document.getElementById('computationLoadingState');
    const errorState = document.getElementById('computationErrorState');
    const errorMessage = document.getElementById('computationErrorMessage');

    if (loadingState) loadingState.style.display = 'none';
    if (errorState) errorState.style.display = 'block';
    if (errorMessage) errorMessage.textContent = message;
}

/**
 * ?? Update dashboard stats (optional)
 */
function updateDashboard() {
    if (!__currentPayRun) return;

    console.log('?? Updating dashboard stats...');

    // Update stats if elements exist
    const grossElement = document.getElementById('statGross');
    const statusElement = document.getElementById('statStatus');

    if (grossElement) {
        grossElement.textContent = '\u20B1' + (__currentPayRun.totalGrossSalary || 0).toLocaleString('en-PH', { minimumFractionDigits: 2 });
    }

    if (statusElement) {
        statusElement.textContent = __currentPayRun.status || 'Computed';
    }

    console.log('? Dashboard updated');
}

/**
 * ?? Navigate to next step (helper function)
 */
function nextStep(stepNumber) {
    console.log(`?? Moving to step ${stepNumber}...`);

    // Hide all step content
    document.querySelectorAll('.step-content').forEach(content => {
        content.classList.remove('active');
    });

    // Show target step content
    const targetStep = document.getElementById('step' + stepNumber);
    if (targetStep) {
        targetStep.classList.add('active');
        console.log(`? Step ${stepNumber} is now active`);
    }

    // Update stepper indicators
    for (let i = 1; i <= 5; i++) {
        const indicator = document.getElementById('step' + i + 'Indicator');
        if (indicator) {
            indicator.classList.remove('active', 'completed');

            if (i < stepNumber) {
                indicator.classList.add('completed');
            } else if (i === stepNumber) {
                indicator.classList.add('active');
            }
        }
    }

    // Special handling for Step 2 - load employees
    if (stepNumber === 2) {
        console.log('?? Step 2 activated - loading employees...');
        if (typeof loadEmployees === 'function') {
            loadEmployees();
        } else {
            console.warn('?? loadEmployees() function not found');
        }
    }

    // Special handling for Step 4 - load approved payrolls
    if (stepNumber === 4) {
        console.log('💰 Step 4 activated - loading approved payrolls...');
        setTimeout(() => {
            if (typeof loadApprovedPayrolls === 'function') {
                loadApprovedPayrolls();
            } else {
                console.warn('⚠️ loadApprovedPayrolls() function not found');
            }
        }, 100);
    }
}

/**
 * ?? Navigate to previous step (helper function)
 */
function prevStep(stepNumber) {
    console.log(`?? Going back to step ${stepNumber}...`);
    nextStep(stepNumber);
}

/**
 * Send to Finance flow - Navigate to Step 4
 */
async function sendToFinanceFromStep3() {
    if (!__currentPayRun || !__currentPayRun.payRunId) {
        alert('No computed payroll to send. Compute in Step 3 first.');
        return;
    }

    const payRunId = __currentPayRun.payRunId;

    console.log('📤 Sending to Finance...', payRunId);

    // Navigate to Step 4 IMMEDIATELY (don't wait for backend)
    console.log('🔄 Navigating to Step 4...');
    nextStep(4);

    // Then handle backend calls in background
    try {
        // 1) Send to finance (creates journal entry and marks as sent)
        const sendRes = await ajaxPost('Payroll.aspx/SendToFinance', { payRunId: payRunId });

        console.log('📥 SendToFinance response:', sendRes);

        if (sendRes && sendRes.success === true) {
            console.log('✅ Sent to Finance successfully');
        } else {
            console.error('❌ SendToFinance failed:', sendRes);
        }
    } catch (err) {
        console.error('❌ Background processing error:', err);
        console.error('❌ Error stack:', err.stack);
    }
}

/**
 * Load approved payrolls for Step 4
 * 🎯 UPDATED: Filter by status = "Approved" instead of "Calculated"
 * This shows payrolls that have been approved by Finance
 */
async function loadApprovedPayrolls() {
    console.log('========================================');
    console.log('📋 Loading APPROVED payrolls for Step 4...');
    console.log('========================================');

    const loadingState = document.getElementById('financeLoadingState');
    const errorState = document.getElementById('financeErrorState');
    const emptyState = document.getElementById('financeEmptyState');
    const tableContainer = document.getElementById('financeTableContainer');
    const tableBody = document.getElementById('financeTableBody');

    console.log('🔍 Element check:', {
        loadingState: !!loadingState,
        errorState: !!errorState,
        emptyState: !!emptyState,
        tableContainer: !!tableContainer,
        tableBody: !!tableBody
    });

    // Show loading - FORCE display
    if (loadingState) {
        loadingState.style.display = 'block';
        loadingState.style.visibility = 'visible';
        console.log('✅ Loading state shown');
    }
    if (errorState) errorState.style.display = 'none';
    if (emptyState) emptyState.style.display = 'none';
    if (tableContainer) tableContainer.style.display = 'none';

    try {
        // Fetch all payroll history using the handler
        console.log('📡 Calling GetPayrollHistoryHandler...');
        console.log('📡 URL: ../Handler/GetPayrollHistoryHandler.ashx');

        let response;
        try {
            const fetchResponse = await fetch('../Handler/GetPayrollHistoryHandler.ashx', {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                    'Cache-Control': 'no-cache'
                }
            });

            console.log('📡 Fetch response status:', fetchResponse.status);
            console.log('📡 Fetch response ok:', fetchResponse.ok);

            if (!fetchResponse.ok) {
                throw new Error(`HTTP error! status: ${fetchResponse.status}`);
            }

            response = await fetchResponse.json();
            console.log('📥 Response received:', response);
        } catch (fetchError) {
            console.error('❌ Fetch error:', fetchError);
            throw new Error(`Failed to fetch payroll data: ${fetchError.message}`);
        }

        if (!response || !response.success) {
            const errorMsg = response?.message || 'Failed to load payrolls - no success flag';
            console.error('❌ Response not successful:', errorMsg);
            throw new Error(errorMsg);
        }

        if (!response.data) {
            console.warn('⚠️ No data in response');
            response.data = [];
        }

        console.log(`📊 Total payrolls in database: ${response.data.length}`);

        // 🎯 CRITICAL: Filter only APPROVED payrolls (not Calculated)
        const approvedPayrolls = (response.data || []).filter(pr => {
            const isApproved = pr.status === 'Approved';
            console.log(`Checking payroll ${pr.payRunNumber}: status = "${pr.status}" → ${isApproved ? '✅ APPROVED' : '❌ NOT APPROVED'}`);
            return isApproved;
        });

        console.log(`✅ Found ${approvedPayrolls.length} APPROVED payrolls out of ${response.data.length} total`);

        // Hide loading
        if (loadingState) {
            loadingState.style.display = 'none';
            console.log('✅ Loading state hidden');
        }

        if (approvedPayrolls.length === 0) {
            console.log('ℹ️ No approved payrolls found - showing empty state');
            if (emptyState) {
                emptyState.style.display = 'block';
                emptyState.style.visibility = 'visible';
            }
            return;
        }

        // Populate table with approved payrolls
        if (tableBody) {
            console.log('📝 Populating table body...');
            tableBody.innerHTML = '';

            approvedPayrolls.forEach((payroll, index) => {
                console.log(`📝 Rendering approved payroll ${index + 1}:`, {
                    id: payroll.id,
                    payRunNumber: payroll.payRunNumber,
                    status: payroll.status,
                    employees: payroll.totalEmployees,
                    totalNet: payroll.totalNetSalary
                });

                const row = document.createElement('tr');
                row.style.borderBottom = '1px solid #E5E7EB';
                row.innerHTML = `
                    <td style="padding:16px;"><strong>${payroll.payRunNumber || 'N/A'}</strong></td>
                    <td style="padding:16px;">${payroll.period || 'N/A'}</td>
                    <td style="padding:16px; text-align:center;">${payroll.totalEmployees || 0}</td>
                    <td style="padding:16px; text-align:right; color:#059669; font-weight:600;">₱${(payroll.totalGrossSalary || 0).toLocaleString('en-PH', { minimumFractionDigits: 2 })}</td>
                    <td style="padding:16px; text-align:right; color:#6B7280; font-weight:600;">₱${(payroll.totalDeductions || 0).toLocaleString('en-PH', { minimumFractionDigits: 2 })}</td>
                    <td style="padding:16px; text-align:right; color:#2563EB; font-weight:700;">₱${(payroll.totalNetSalary || 0).toLocaleString('en-PH', { minimumFractionDigits: 2 })}</td>
                    <td style="padding:16px;"><span class="status-badge status-approved" style="background:#D1FAE5;color:#065F46;padding:4px 12px;border-radius:12px;font-size:12px;font-weight:600;">✅ ${payroll.status}</span></td>
                    <td style="padding:16px;">
                        <button type="button" class="btn btn-sm btn-success" onclick="sendPayslips('${payroll.id}')" style="padding:8px 16px;background:#10B981;color:white;border:none;border-radius:6px;cursor:pointer;font-size:14px;">
                            📧 Send Payslips
                        </button>
                    </td>
                `;
                tableBody.appendChild(row);
            });

            console.log(`✅ Rendered ${approvedPayrolls.length} approved payrolls in table`);
        } else {
            console.error('❌ tableBody element not found!');
        }

        // Show table container
        if (tableContainer) {
            tableContainer.style.display = 'block';
            tableContainer.style.visibility = 'visible';
            console.log('✅ Table container shown');
        } else {
            console.error('❌ tableContainer element not found!');
        }

        console.log('========================================');
        console.log('✅ loadApprovedPayrolls COMPLETE');
        console.log('========================================');

    } catch (error) {
        console.error('========================================');
        console.error('❌ Error loading approved payrolls:', error);
        console.error('❌ Error message:', error.message);
        console.error('❌ Error stack:', error.stack);
        console.error('========================================');

        // Hide loading
        if (loadingState) {
            loadingState.style.display = 'none';
        }

        // Show error state
        if (errorState) {
            errorState.style.display = 'block';
            errorState.style.visibility = 'visible';
            const errorMessage = document.getElementById('financeErrorMessage');
            if (errorMessage) {
                errorMessage.textContent = error.message || 'Unknown error';
            }
            console.log('✅ Error state shown');
        }
    }
}

/**
 * Send payslips for an approved payroll
 * 📧 This function sends payslips to all employees in the approved payroll
 */
async function sendPayslips(payRunId) {
    if (!confirm('Are you sure you want to send payslips for this payroll?\n\nPayslips will be sent via email to all employees in this payroll run.')) {
        return;
    }

    // Get the button that was clicked
    const button = event?.target;
    const originalText = button ? button.innerHTML : '';

    try {
        console.log(`========================================`);
        console.log(`📧 Sending payslips for payroll: ${payRunId}`);
        console.log(`========================================`);

        // Show loading indicator
        if (button) {
            button.disabled = true;
            button.innerHTML = '⏳ Sending...';
            button.style.opacity = '0.6';
        }

        // Call backend to send payslips
        const response = await fetch('../Handler/SendPayslipsHandler.ashx', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                payRunId: payRunId,
                sentBy: 'HR Admin'
            })
        }).then(res => res.json());

        console.log('📥 SendPayslips response:', response);

        if (!response || !response.success) {
            throw new Error(response?.message || 'Failed to send payslips');
        }

        // Success! Show detailed results
        console.log('✅ Payslips sent successfully!');
        console.log(`   Emails sent: ${response.data?.emailsSent || 0}`);
        console.log(`   Emails failed: ${response.data?.emailsFailed || 0}`);

        // Build detailed message
        let alertMessage = response.message || 'Payslips sent successfully!';

        if (response.data) {
            alertMessage += `\n\n📊 Summary:`;
            alertMessage += `\n• Total Employees: ${response.data.totalEmployees || 0}`;
            alertMessage += `\n• Emails Sent: ${response.data.emailsSent || 0}`;
            alertMessage += `\n• Emails Failed: ${response.data.emailsFailed || 0}`;

            // Show failed employees if any
            if (response.data.failedEmployees && response.data.failedEmployees.length > 0) {
                alertMessage += `\n\n❌ Failed to send to:`;
                response.data.failedEmployees.forEach(emp => {
                    alertMessage += `\n• ${emp}`;
                });
                alertMessage += `\n\n💡 Tip: Check that all employees have valid email addresses in the system.`;
            }
        }

        alert(alertMessage);

        // Restore button
        if (button) {
            button.disabled = false;
            button.innerHTML = '✅ Sent';
            button.style.opacity = '1';
            button.style.background = '#059669';

            // Reset button after 3 seconds
            setTimeout(() => {
                button.innerHTML = originalText;
                button.style.background = '';
            }, 3000);
        }

        // Reload the approved payrolls table
        loadApprovedPayrolls();

    } catch (error) {
        console.error('========================================');
        console.error('❌ Error sending payslips:', error);
        console.error('========================================');

        // Restore button
        if (button) {
            button.disabled = false;
            button.innerHTML = originalText;
            button.style.opacity = '1';
        }

        alert('❌ Failed to send payslips\n\n' + (error.message || 'Unknown error') + '\n\nPlease check:\n• SMTP settings are configured in Web.config\n• Employees have valid email addresses\n• Visual Studio Output window for details');
    }
}

/**
 * Inject and Show Approval Modal
 */
function showApprovalModal() {
    // Inject modal HTML if not exists
    if (!document.getElementById('approvalSuccessModal')) {
        const modalHtml = `
            <div id="approvalSuccessModal" style="display:none; position:fixed; z-index:9999; left:0; top:0; width:100%; height:100%; overflow:auto; background-color:rgba(0,0,0,0.5);">
                <div style="background-color:#fefefe; margin:15% auto; padding:20px; border:1px solid #888; width:400px; border-radius:8px; text-align:center; box-shadow: 0 4px 8px rgba(0,0,0,0.2);">
                    <div style="color:#28a745; font-size:48px; margin-bottom:10px;">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <h2 style="color:#333; margin-top:0;">Payroll Approved!</h2>
                    <p style="color:#666; margin:15px 0;">The payroll has been successfully approved by Finance.</p>
                    <button id="btnApprovalNext" style="background-color:#28a745; color:white; padding:10px 20px; border:none; border-radius:4px; cursor:pointer; font-size:16px; margin-top:10px;">
                        Next <i class="fas fa-arrow-right"></i>
                    </button>
                </div>
            </div>
        `;
        document.body.insertAdjacentHTML('beforeend', modalHtml);

        // Bind click event
        document.getElementById('btnApprovalNext').onclick = function () {
            document.getElementById('approvalSuccessModal').style.display = 'none';
            nextStep(4); // Go to Step 4 (Payslips)
        };
    }

    // Show modal
    document.getElementById('approvalSuccessModal').style.display = 'block';
}

// Helper: POST to ASP.NET WebMethod and parse `d`
function ajaxPost(url, payload) {
    return new Promise((resolve, reject) => {
        $.ajax({
            type: 'POST', url: url,
            contentType: 'application/json; charset=utf-8', dataType: 'json',
            data: JSON.stringify(payload || {}), timeout: 90000,
            success: function (resp) {
                try {
                    let d = resp && resp.d !== undefined ? resp.d : resp;
                    if (typeof d === 'string') d = JSON.parse(d);
                    resolve(d);
                } catch { resolve(resp); }
            },
            error: function (xhr, status, err) { reject(err || status || 'error'); }
        });
    });
}

// Helper: download text as file
function downloadTextFile(fileName, content) {
    if (!content) return;
    const blob = new Blob([content], { type: 'text/plain;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url; a.download = fileName || 'download.txt';
    document.body.appendChild(a); a.click(); a.remove();
    URL.revokeObjectURL(url);
}

// Hook Step 4 button click without editing ASPX
$(document).on('click', '#step4 .btn-success[data-bound!=true]', function (e) {
    // This delegated handler is a fallback; see explicit binding below
    e.preventDefault();
    e.stopImmediatePropagation();
    sendToFinance();
});

// Explicitly remove inline onclick and bind our handler when DOM is ready
$(function () {
    var $btn = $('#step4 .btn-success');
    if ($btn.length) {
        try { $btn.removeAttr('onclick'); } catch (_) { }
        $btn.off('click').attr('data-bound', 'true').on('click', function (e) {
            e.preventDefault();
            e.stopImmediatePropagation();
            sendToFinance();
        });
        console.log('? Step 4 Send to Finance button rebound');
    }
});

console.log('✅ generatePayroll-fixed.js loaded (v3.2 - Approved Payrolls & Send Payslips)');
console.log('📋 Functions available: generatePayroll, renderPayrollComputations, nextStep, prevStep, sendToFinanceFromStep3, loadApprovedPayrolls, sendPayslips');
