/**
 * PAYROLL SUBMISSION HANDLER
 * Handles Step 4 (Submit to Finance) and Step 5 (Awaiting Finance Approval)
 * Version: 1.0.0
 */

/**
 * Submit payroll to Finance for approval
 */
function submitToFinance() {
    console.log('?? Submitting payroll to Finance...');
    
    if (!__currentPayRun || !__currentPayRun.items || __currentPayRun.items.length === 0) {
        alert('No payroll data to submit. Please complete Steps 1-3 first.');
        return;
    }
    
    // Collect remarks from review table
    document.querySelectorAll('#step4TableBody .remarks-cell').forEach(cell => {
        const empId = cell.getAttribute('data-employee-id');
        const remarks = cell.textContent.trim();
        
        if (empId && __currentPayRun.items) {
            const item = __currentPayRun.items.find(i => i.employeeId === empId);
            if (item && remarks !== '(Optional)') {
                item.remarks = remarks;
            }
        }
    });
    
    // Get form values
    const startDateInput = document.getElementById(getClientId('txtStartDate'));
    const endDateInput = document.getElementById(getClientId('txtEndDate'));
    const cutoffDateInput = document.getElementById(getClientId('txtCutoffDate'));
    
    // Prepare submission data
    const submissionData = {
        payRunId: __currentPayRun.id || generatePayRunId(),
        status: 'Pending Finance Approval',
        submittedBy: 'HR Department', // TODO: Get from session
        submittedAt: new Date().toISOString(),
        period: __currentPayRun.period,
        startDate: startDateInput ? startDateInput.value : '',
        endDate: endDateInput ? endDateInput.value : '',
        cutoffDate: cutoffDateInput ? cutoffDateInput.value : '',
        totalEmployees: __currentPayRun.items.length,
        totalGross: __currentPayRun.totalGross || 0,
        totalNet: __currentPayRun.totalNet || 0,
        items: __currentPayRun.items
    };
    
    console.log('?? Submission data:', submissionData);
    
    // Call server to save and notify Finance
    $.ajax({
        type: 'POST',
        url: 'Payroll.aspx/SubmitToFinance',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        data: JSON.stringify({ payrollData: submissionData }),
        success: function(response) {
            console.log('? Submission successful:', response);
            
            // Update global state
            __currentPayRun.status = 'Pending Finance Approval';
            __currentPayRun.submittedAt = submissionData.submittedAt;
            
            // Populate Step 5 with submission details
            populateStep5SubmissionDetails(submissionData);
            
            // Move to Step 5
            nextStep(5);
            
            // Update dashboard
            updateDashboard();
        },
        error: function(xhr, status, error) {
            console.error('? Submission failed:', error);
            
            let errorMessage = 'Failed to submit payroll to Finance: ' + error;
            
            if (xhr.responseJSON && xhr.responseJSON.Message) {
                errorMessage = xhr.responseJSON.Message;
            } else if (xhr.responseText) {
                try {
                    const errorData = JSON.parse(xhr.responseText);
                    if (errorData.Message) {
                        errorMessage = errorData.Message;
                    }
                } catch (e) {
                    // Ignore parse error
                }
            }
            
            alert(errorMessage + '\n\nPlease try again or contact IT support.');
        }
    });
}

/**
 * Populate Step 5 with submission details
 */
function populateStep5SubmissionDetails(data) {
    console.log('?? Populating Step 5 submission details...');
    
    // Format timestamp
    const timestamp = new Date(data.submittedAt);
    const formattedTime = timestamp.toLocaleString('en-PH', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
    
    // Update submission details
    const timestampEl = document.getElementById('submissionTimestamp');
    const periodEl = document.getElementById('submissionPeriod');
    const countEl = document.getElementById('submissionEmployeeCount');
    const grossEl = document.getElementById('submissionTotalGross');
    
    if (timestampEl) timestampEl.textContent = formattedTime;
    if (periodEl) periodEl.textContent = data.period || 'N/A';
    if (countEl) countEl.textContent = data.totalEmployees || 0;
    if (grossEl) grossEl.textContent = '?' + (data.totalGross || 0).toLocaleString('en-PH', {minimumFractionDigits: 2});
    
    console.log('? Step 5 populated with submission details');
}

/**
 * View submitted payroll data
 */
function viewSubmittedPayroll() {
    console.log('??? Viewing submitted payroll...');
    
    if (!__currentPayRun || !__currentPayRun.items) {
        alert('No submitted payroll data available.');
        return;
    }
    
    // Go back to Step 4 (read-only mode)
    prevStep(4);
    
    // Show info message
    setTimeout(() => {
        alert('Viewing submitted payroll (read-only mode).\n\nTo make changes, please contact Finance to recall the submission.');
    }, 500);
}

/**
 * Generate unique PayRun ID
 */
function generatePayRunId() {
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 10000);
    return 'PR' + timestamp + '-' + random;
}

/**
 * Helper function to get ASP.NET control client ID
 */
function getClientId(controlId) {
    // Try to find by exact ID first
    let element = document.getElementById(controlId);
    if (element) return controlId;
    
    // Search for element with ID ending with controlId (ASP.NET naming)
    const allElements = document.querySelectorAll('[id$="' + controlId + '"]');
    if (allElements.length > 0) {
        return allElements[0].id;
    }
    
    return controlId; // Return original if not found
}

console.log('? Payroll submission handler loaded');
