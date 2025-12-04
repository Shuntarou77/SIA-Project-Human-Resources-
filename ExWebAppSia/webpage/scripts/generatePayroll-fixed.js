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
        success: function(response) {
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
        error: function(xhr, textStatus, errorThrown) {
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
                        <span class="item-value">\u20B1${(item.basicSalary || 0).toLocaleString('en-PH', {minimumFractionDigits: 2})}</span>
                    </div>
                    <div class="computation-item">
                        <span class="item-label">Allowances</span>
                        <span class="item-value">\u20B1${(item.totalAllowances || 0).toLocaleString('en-PH', {minimumFractionDigits: 2})}</span>
                    </div>
                    <div class="computation-item">
                        <span class="item-label">Overtime</span>
                        <span class="item-value">\u20B1${(item.overtimePay || 0).toLocaleString('en-PH', {minimumFractionDigits: 2})}</span>
                    </div>
                    <div class="computation-item total-row">
                        <span class="item-label">Gross Salary</span>
                        <span class="item-value">\u20B1${(item.grossSalary || 0).toLocaleString('en-PH', {minimumFractionDigits: 2})}</span>
                    </div>
                </div>
                <div class="computation-section">
                    <div class="section-title">Deductions</div>
                    <div class="computation-item">
                        <span class="item-label">SSS</span>
                        <span class="item-value">\u20B1${(item.sssContribution || 0).toLocaleString('en-PH', {minimumFractionDigits: 2})}</span>
                    </div>
                    <div class="computation-item">
                        <span class="item-label">PhilHealth</span>
                        <span class="item-value">\u20B1${(item.philHealthContribution || 0).toLocaleString('en-PH', {minimumFractionDigits: 2})}</span>
                    </div>
                    <div class="computation-item">
                        <span class="item-label">Pag-IBIG</span>
                        <span class="item-value">\u20B1${(item.pagIbigContribution || 0).toLocaleString('en-PH', {minimumFractionDigits: 2})}</span>
                    </div>
                    <div class="computation-item">
                        <span class="item-label">Withholding Tax</span>
                        <span class="item-value">\u20B1${(item.withholdingTax || 0).toLocaleString('en-PH', {minimumFractionDigits: 2})}</span>
                    </div>
                    <div class="computation-item total-row">
                        <span class="item-label">Total Deductions</span>
                        <span class="item-value">\u20B1${(item.totalDeductions || 0).toLocaleString('en-PH', {minimumFractionDigits: 2})}</span>
                    </div>
                </div>
            </div>
            <div class="net-salary-box">
                <div class="net-salary-label">Net Salary</div>
                <div class="net-salary-value">\u20B1${(item.netSalary || 0).toLocaleString('en-PH', {minimumFractionDigits: 2})}</div>
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
        grossElement.textContent = '\u20B1' + (__currentPayRun.totalGrossSalary || 0).toLocaleString('en-PH', {minimumFractionDigits: 2});
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
}

/**
 * ?? Navigate to previous step (helper function)
 */
function prevStep(stepNumber) {
    console.log(`?? Going back to step ${stepNumber}...`);
    nextStep(stepNumber);
}

/**
 * Send to Finance flow: Approve -> Send -> Export JE CSV -> Generate bank file
 */
async function sendToFinance() {
    try {
        const btn = document.querySelector('#step4 .btn-success');
        if (!__currentPayRun || !__currentPayRun.payRunId) {
            alert('No computed payroll to send. Compute in Step 3 first.');
            return;
        }
        if (btn) { btn.disabled = true; btn.textContent = 'Sending...'; }
        const payRunId = __currentPayRun.payRunId;

        // 1) Approve
        const approveRes = await ajaxPost('Payroll.aspx/ApprovePayRun', { payRunId: payRunId, approvedBy: 'HR Admin', comments: 'Approved via web' });
        if (!approveRes || approveRes.success !== true) {
            throw new Error((approveRes && approveRes.message) || 'Failed to approve pay run');
        }

        // 2) Send to finance (creates journal entry)
        const sendRes = await ajaxPost('Payroll.aspx/SendToFinance', { payRunId: payRunId });
        if (!sendRes || sendRes.success !== true) {
            throw new Error((sendRes && sendRes.message) || 'Failed to send to finance');
        }
        const entryNumber = sendRes.journalEntryNumber;

        // 3) Export journal entry CSV (best-effort)
        try {
            const jeList = await ajaxPost('Payroll.aspx/GetJournalEntries', {});
            const found = jeList && jeList.data ? jeList.data.find(j => j.entryNumber === entryNumber) : null;
            if (found) {
                const exp = await ajaxPost('Payroll.aspx/ExportJournalEntry', { journalEntryId: found.id, format: 'csv' });
                if (exp && exp.success) {
                    downloadTextFile(exp.fileName, exp.content);
                }
            }
        } catch (e) { console.warn('Journal export skipped:', e); }

        // 4) Generate bank transfer file and download (best-effort)
        try {
            const bank = await ajaxPost('Payroll.aspx/GenerateBankTransferFile', { payRunId: payRunId });
            if (bank && bank.success && bank.fileName && bank.fileContent) {
                downloadTextFile(bank.fileName, bank.fileContent);
            }
        } catch (e2) { console.warn('Bank file generation skipped:', e2); }

        // 5) Go to Step 5
        nextStep(5);
    } catch (err) {
        console.error('SendToFinance failed:', err);
        alert('Send to Finance failed: ' + (err && err.message ? err.message : err));
    } finally {
        const btn = document.querySelector('#step4 .btn-success');
        if (btn) { btn.disabled = false; btn.textContent = 'Send to Finance'; }
    }
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
$(function(){
    var $btn = $('#step4 .btn-success');
    if ($btn.length) {
        try { $btn.removeAttr('onclick'); } catch(_) {}
        $btn.off('click').attr('data-bound','true').on('click', function(e){
            e.preventDefault();
            e.stopImmediatePropagation();
            sendToFinance();
        });
        console.log('? Step 4 Send to Finance button rebound');
    }
});

console.log('? generatePayroll-fixed.js loaded (v3.0)');
console.log('? Functions available: generatePayroll, renderPayrollComputations, nextStep, prevStep');
console.log('? Send-to-Finance client flow wired');
