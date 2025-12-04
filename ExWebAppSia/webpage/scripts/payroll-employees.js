// PAYROLL EMPLOYEE LOADING HANDLER
// Version: 2.0 (2025-12-01) - Fixed to use correct web method
// Purpose: Fetch and display employees from Employees collection ONLY

// Global state for employee data
let __allEmployees = [];
let __filteredEmployees = [];
let __selectedEmployeeIds = new Set();

/**
 * 🔄 Load employees from database (Employees collection ONLY - no Users fallback)
 * Called when Step 2 is activated
 */
function loadEmployees() {
    console.log('========================================');
    console.log('🔄 Loading employees for payroll generation...');
    console.log('========================================');
    
    const loadingState = document.getElementById('employeeLoadingState');
    const errorState = document.getElementById('employeeErrorState');
    const employeeList = document.getElementById('employeeList');
    
    // Show loading, hide error
    loadingState.style.display = 'block';
    errorState.style.display = 'none';
    employeeList.innerHTML = '';
    
    $.ajax({
        type: 'POST',
        url: 'Payroll.aspx/GetEmployees', // ✅ FIXED: Use Payroll.aspx web method
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        timeout: 30000, // 30-second timeout
        success: function(response) {
            console.log('📥 Raw server response:', response);
            
            try {
                let result = response.d;
                
                // Handle wrapped response
                if (typeof result === 'string') {
                    result = JSON.parse(result);
                }
                
                console.log('📦 Parsed result:', result);
                
                // Check if response has success flag
                if (result && result.success === false) {
                    console.error('❌ Server returned error:', result.message);
                    showEmployeeError(result.message || 'Unknown error loading employees');
                    return;
                }
                
                // Extract data array
                const employees = result.success ? result.data : result;
                
                if (employees && Array.isArray(employees)) {
                    __allEmployees = employees;
                    console.log(`✅ Loaded ${employees.length} employees from Employees collection`);
                    
                    if (employees.length === 0) {
                        console.log('⚠️ No employees found in database');
                        showEmployeeError('No employees found in the Employees collection.\n\nPlease hire employees in the Recruitment module first.');
                    } else {
                        // Display employees
                        renderEmployeeList(employees);
                        
                        // Hide loading, show list
                        loadingState.style.display = 'none';
                        employeeList.style.display = 'block';
                        
                        // Update employee count
                        updateEmployeeCount();
                        
                        console.log('✅ Employee list rendered successfully');
                        console.log('📋 First 3 employees:', employees.slice(0, 3).map(e => `${e.employeeNumber}: ${e.fullName}`));
                    }
                } else {
                    console.error('❌ Invalid response format:', result);
                    showEmployeeError('Invalid response format from server');
                }
            } catch (parseError) {
                console.error('❌ Error parsing response:', parseError);
                console.error('❌ Stack:', parseError.stack);
                showEmployeeError('Error parsing server response: ' + parseError.message);
            }
        },
        error: function(xhr, status, error) {
            console.error('❌ AJAX error loading employees:', {
                status: status,
                error: error,
                statusText: xhr.statusText,
                responseText: xhr.responseText ? xhr.responseText.substring(0, 500) : 'N/A'
            });
            
            let errorMessage = 'Failed to load employees from database.\n\n';
            
            if (status === 'timeout') {
                errorMessage += '⏱️ Request timed out after 30 seconds.\n\n';
                errorMessage += 'This usually means:\n';
                errorMessage += '• MongoDB Atlas is slow or unreachable\n';
                errorMessage += '• Network firewall is blocking the request\n';
                errorMessage += '• Database is under heavy load\n\n';
                errorMessage += 'Please check MongoDB Atlas status and try again.';
            } else if (xhr.status === 500) {
                errorMessage += '❌ Server error (500).\n\n';
                errorMessage += 'Check:\n';
                errorMessage += '• MongoDB connection string is correct\n';
                errorMessage += '• Employees collection exists in database\n';
                errorMessage += '• Server logs for detailed error\n\n';
                
                // Try to extract error message from response
                if (xhr.responseText) {
                    try {
                        const match = xhr.responseText.match(/<title>([^<]+)<\/title>/);
                        if (match) {
                            errorMessage += '\nServer says: ' + match[1];
                        }
                    } catch (e) {
                        // Ignore parsing errors
                    }
                }
                
                errorMessage += '\n\nError: ' + error;
            } else {
                errorMessage += '❌ Error: ' + error + '\n';
                errorMessage += 'Status: ' + status;
            }
            
            showEmployeeError(errorMessage);
        }
    });
}

/**
 * 🎨 Render employee list as cards
 */
function renderEmployeeList(employees) {
    const employeeList = document.getElementById('employeeList');
    employeeList.innerHTML = '';
    
    if (!employees || employees.length === 0) {
        employeeList.innerHTML = '<p style="text-align:center;color:#666;padding:40px;">No employees available for payroll</p>';
        return;
    }
    
    console.log(`🎨 Rendering ${employees.length} employees...`);
    
    employees.forEach((emp, index) => {
        const card = document.createElement('div');
        card.className = 'employee-card selected'; // Selected by default
        card.dataset.employeeId = emp.employeeId;
        
        // Add to selected set
        __selectedEmployeeIds.add(emp.employeeId);
        
        card.innerHTML = `
            <input type="checkbox" class="checkbox employee-checkbox" 
                   data-employee-id="${emp.employeeId}" 
                   checked 
                   onchange="toggleEmployeeSelection('${emp.employeeId}')">
            <div class="employee-info">
                <div class="info-item">
                    <div class="info-label">Emp No.</div>
                    <div class="info-value">${emp.employeeNumber || 'N/A'}</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Name</div>
                    <div class="info-value">${emp.fullName || 'N/A'}</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Department</div>
                    <div class="info-value">${emp.department || 'N/A'}</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Position</div>
                    <div class="info-value">${emp.position || 'Employee'}</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Type</div>
                    <div class="info-value">
                        <span class="badge ${emp.employmentType === 'Regular' ? 'badge-regular' : 'badge-contractual'}">
                            ${emp.employmentType || 'Regular'}
                        </span>
                    </div>
                </div>
            </div>
        `;
        
        employeeList.appendChild(card);
    });
    
    console.log(`✅ Rendered ${employees.length} employee cards`);
    
    // Store filtered employees
    __filteredEmployees = employees;
}

/**
 * ✅ Toggle employee selection
 */
function toggleEmployeeSelection(employeeId) {
    const checkbox = document.querySelector(`.employee-checkbox[data-employee-id="${employeeId}"]`);
    const card = checkbox.closest('.employee-card');
    
    if (checkbox.checked) {
        __selectedEmployeeIds.add(employeeId);
        card.classList.add('selected');
    } else {
        __selectedEmployeeIds.delete(employeeId);
        card.classList.remove('selected');
    }
    
    updateEmployeeCount();
    console.log(`${checkbox.checked ? '✅' : '❌'} Employee ${employeeId} ${checkbox.checked ? 'selected' : 'deselected'}`);
}

/**
 * 🔄 Toggle select all employees
 */
function toggleSelectAll() {
    const selectAllCheckbox = document.getElementById('selectAll');
    const allCheckboxes = document.querySelectorAll('.employee-checkbox');
    
    allCheckboxes.forEach(checkbox => {
        checkbox.checked = selectAllCheckbox.checked;
        const employeeId = checkbox.dataset.employeeId;
        const card = checkbox.closest('.employee-card');
        
        if (selectAllCheckbox.checked) {
            __selectedEmployeeIds.add(employeeId);
            card.classList.add('selected');
        } else {
            __selectedEmployeeIds.delete(employeeId);
            card.classList.remove('selected');
        }
    });
    
    updateEmployeeCount();
    console.log(`${selectAllCheckbox.checked ? '✅' : '❌'} All employees ${selectAllCheckbox.checked ? 'selected' : 'deselected'}`);
}

/**
 * 📊 Update employee count display
 */
function updateEmployeeCount() {
    const countElement = document.getElementById('employeeCount');
    if (countElement) {
        countElement.textContent = __selectedEmployeeIds.size;
    }
}

/**
 * ❌ Show error state for employee loading
 */
function showEmployeeError(message) {
    const loadingState = document.getElementById('employeeLoadingState');
    const errorState = document.getElementById('employeeErrorState');
    const errorMessage = document.getElementById('employeeErrorMessage');
    
    loadingState.style.display = 'none';
    errorState.style.display = 'block';
    errorMessage.textContent = message;
    
    console.error('❌ Employee loading error:', message);
}

/**
 * 🔍 Filter employees based on search and department
 */
function filterEmployees() {
    const searchTerm = document.getElementById('searchEmployees')?.value.toLowerCase() || '';
    const deptFilter = document.getElementById('filterDept')?.value || '';
    const roleFilter = document.getElementById('filterRole')?.value || '';
    
    const filtered = __allEmployees.filter(emp => {
        const matchesSearch = !searchTerm || 
            (emp.fullName || '').toLowerCase().includes(searchTerm) ||
            (emp.employeeNumber || '').toLowerCase().includes(searchTerm) ||
            (emp.department || '').toLowerCase().includes(searchTerm);
        
        const matchesDept = !deptFilter || emp.department === deptFilter;
        const matchesRole = !roleFilter || emp.position === roleFilter;
        
        return matchesSearch && matchesDept && matchesRole;
    });
    
    renderEmployeeList(filtered);
    console.log(`🔍 Filtered: ${filtered.length} of ${__allEmployees.length} employees`);
}

// Attach filter event listeners when DOM is ready
$(document).ready(function() {
    const searchInput = document.getElementById('searchEmployees');
    const deptFilter = document.getElementById('filterDept');
    const roleFilter = document.getElementById('filterRole');
    
    if (searchInput) {
        searchInput.addEventListener('input', filterEmployees);
    }
    if (deptFilter) {
        deptFilter.addEventListener('change', filterEmployees);
    }
    if (roleFilter) {
        roleFilter.addEventListener('change', filterEmployees);
    }
    
    console.log('✅ Payroll employee filter handlers attached');
});

console.log('✅ Payroll employee handlers loaded (v2.0 - Employees collection only)');
