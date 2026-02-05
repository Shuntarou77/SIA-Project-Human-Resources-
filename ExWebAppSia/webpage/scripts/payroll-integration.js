// PAYROLL CONFIGURATION TAB - JavaScript Handlers
// Version: 2.0 (2025-01-28)

// Global state
let __currentConfigMode = null; // 'create' or 'edit'
let __currentConfigId = null;
let __employeesWithoutConfig = [];

/**
 * ?? Open Configuration Modal
 */
function openConfigModal(mode, configId) {
    console.log('[openConfigModal] Opening config modal:', mode, configId);
    
    try {
        __currentConfigMode = mode;
        __currentConfigId = configId;
        
        const modal = document.getElementById('configModal');
        if (!modal) {
            console.error('[openConfigModal] Modal element not found! ID: configModal');
            alert('Configuration modal not found. Please refresh the page.');
            return;
        }
        
        console.log('[openConfigModal] Modal element found:', modal);
        
        const modalTitle = document.getElementById('configModalTitle');
        const employeeSelect = document.getElementById('configEmployeeSelect');
        const employeeInfo = document.getElementById('configEmployeeInfo');
        const autoPopulateInstruction = document.getElementById('autoPopulateInstruction');
        
        if (!modalTitle) {
            console.error('[openConfigModal] Modal title element not found!');
        }
        if (!employeeSelect) {
            console.error('[openConfigModal] Employee select element not found!');
        }
        if (!employeeInfo) {
            console.error('[openConfigModal] Employee info element not found!');
        }
        if (!autoPopulateInstruction) {
            console.error('[openConfigModal] Auto populate instruction element not found!');
        }
        
        if (mode === 'create') {
            if (modalTitle) modalTitle.textContent = 'Add New Payroll Configuration';
            if (employeeSelect) employeeSelect.style.display = 'block';
            if (employeeInfo) employeeInfo.style.display = 'none';
            if (autoPopulateInstruction) autoPopulateInstruction.style.display = 'block';
            
            // Load employees without config
            if (typeof loadEmployeesForConfigModal === 'function') {
                loadEmployeesForConfigModal();
            } else {
                console.warn('[openConfigModal] loadEmployeesForConfigModal function not found');
            }
            
            // Reset form
            if (typeof resetConfigForm === 'function') {
                resetConfigForm();
            } else {
                console.warn('[openConfigModal] resetConfigForm function not found');
            }
            
            // Set default effective date (today)
            const effectiveDateInput = document.getElementById('configEffectiveDate');
            if (effectiveDateInput) {
                effectiveDateInput.valueAsDate = new Date();
            } else {
                console.warn('[openConfigModal] configEffectiveDate element not found');
            }
        } else if (mode === 'edit') {
            if (modalTitle) modalTitle.textContent = 'Edit Payroll Configuration';
            if (employeeSelect) employeeSelect.style.display = 'none';
            if (employeeInfo) employeeInfo.style.display = 'block';
            if (autoPopulateInstruction) autoPopulateInstruction.style.display = 'none';
            
            // Load existing configuration
            if (typeof loadConfigurationForEdit === 'function') {
                loadConfigurationForEdit(configId);
            } else {
                console.warn('[openConfigModal] loadConfigurationForEdit function not found');
            }
        }
        
        // Check parent elements for visibility issues
        var parent = modal.parentElement;
        var parentChain = [];
        while (parent && parent !== document.body) {
            var parentDisplay = window.getComputedStyle(parent).display;
            var parentVisibility = window.getComputedStyle(parent).visibility;
            parentChain.push({
                tag: parent.tagName,
                id: parent.id,
                class: parent.className,
                display: parentDisplay,
                visibility: parentVisibility
            });
            if (parentDisplay === 'none' || parentVisibility === 'hidden') {
                console.warn('[openConfigModal] Parent element is hiding modal:', parent);
                parent.style.display = 'block';
                parent.style.visibility = 'visible';
            }
            parent = parent.parentElement;
        }
        console.log('[openConfigModal] Parent element chain:', parentChain);
        
        // Show modal with explicit styles - use multiple methods to ensure it shows
        // Set all styles directly first with explicit dimensions
        modal.style.cssText = 'display: flex !important; visibility: visible !important; opacity: 1 !important; z-index: 99999 !important; position: fixed !important; top: 0 !important; left: 0 !important; width: 100vw !important; height: 100vh !important; min-width: 100vw !important; min-height: 100vh !important; background: rgba(0,0,0,0.7) !important; justify-content: center !important; align-items: center !important; overflow: auto !important;';
        
        // Also set individual properties as backup
        modal.style.display = 'flex';
        modal.style.visibility = 'visible';
        modal.style.opacity = '1';
        modal.style.zIndex = '99999';
        modal.style.position = 'fixed';
        modal.style.top = '0';
        modal.style.left = '0';
        modal.style.width = '100vw';
        modal.style.height = '100vh';
        modal.style.minWidth = '100vw';
        modal.style.minHeight = '100vh';
        modal.style.background = 'rgba(0,0,0,0.7)';
        modal.style.justifyContent = 'center';
        modal.style.alignItems = 'center';
        modal.style.overflow = 'auto';
        
        modal.classList.remove('hidden');
        modal.classList.add('show');
        
        // Ensure modal-content is also visible with explicit dimensions
        var modalContent = modal.querySelector('.modal-content');
        if (modalContent) {
            modalContent.style.cssText = 'display: block !important; visibility: visible !important; opacity: 1 !important; background: white !important; width: 90% !important; max-width: 900px !important; max-height: 90vh !important; border-radius: 16px !important; padding: 30px !important; position: relative !important; overflow-y: auto !important; margin: auto !important;';
            modalContent.style.display = 'block';
            modalContent.style.visibility = 'visible';
            modalContent.style.opacity = '1';
            modalContent.style.width = '90%';
            modalContent.style.maxWidth = '900px';
            modalContent.style.maxHeight = '90vh';
            modalContent.style.margin = 'auto';
            console.log('[openConfigModal] Modal content element found and made visible with dimensions');
        } else {
            console.warn('[openConfigModal] Modal content element not found!');
        }
        
        console.log('[openConfigModal] Modal display set to flex');
        console.log('[openConfigModal] Modal inline style:', modal.style.display);
        console.log('[openConfigModal] Modal computed style:', window.getComputedStyle(modal).display);
        console.log('[openConfigModal] Modal visibility:', window.getComputedStyle(modal).visibility);
        console.log('[openConfigModal] Modal z-index:', window.getComputedStyle(modal).zIndex);
        console.log('[openConfigModal] Modal position:', window.getComputedStyle(modal).position);
        console.log('[openConfigModal] Modal bounding rect:', modal.getBoundingClientRect());
        
        // Double-check after a short delay
        setTimeout(function() {
            var computedDisplay = window.getComputedStyle(modal).display;
            var boundingRect = modal.getBoundingClientRect();
            console.log('[openConfigModal] After 100ms - Computed display:', computedDisplay);
            console.log('[openConfigModal] After 100ms - Bounding rect:', boundingRect);
            
            if (computedDisplay !== 'flex' && computedDisplay !== 'block') {
                console.error('[openConfigModal] Modal still not visible after 100ms! Computed display:', computedDisplay);
                // Try moving modal to body directly
                document.body.appendChild(modal);
                modal.style.cssText = 'display: flex !important; visibility: visible !important; opacity: 1 !important; z-index: 99999 !important; position: fixed !important; top: 0 !important; left: 0 !important; width: 100% !important; height: 100% !important; background: rgba(0,0,0,0.7) !important; justify-content: center !important; align-items: center !important;';
            } else if (boundingRect.width === 0 || boundingRect.height === 0) {
                console.error('[openConfigModal] Modal has zero dimensions! Fixing...');
                // Force explicit dimensions
                modal.style.cssText = 'display: flex !important; visibility: visible !important; opacity: 1 !important; z-index: 99999 !important; position: fixed !important; top: 0 !important; left: 0 !important; width: 100vw !important; height: 100vh !important; min-width: 100vw !important; min-height: 100vh !important; background: rgba(0,0,0,0.7) !important; justify-content: center !important; align-items: center !important; overflow: auto !important;';
                
                // Also ensure modal-content has dimensions
                if (modalContent) {
                    modalContent.style.cssText = 'display: block !important; visibility: visible !important; opacity: 1 !important; background: white !important; width: 90% !important; max-width: 900px !important; max-height: 90vh !important; border-radius: 16px !important; padding: 30px !important; position: relative !important; overflow-y: auto !important; margin: auto !important;';
                }
                
                // Check again after setting dimensions
                setTimeout(function() {
                    var newRect = modal.getBoundingClientRect();
                    console.log('[openConfigModal] After dimension fix - Bounding rect:', newRect);
                    if (newRect.width === 0 || newRect.height === 0) {
                        console.error('[openConfigModal] Still zero dimensions! Moving to body...');
                        // Last resort: move to body
                        if (modal.parentElement !== document.body) {
                            document.body.appendChild(modal);
                            modal.style.cssText = 'display: flex !important; visibility: visible !important; opacity: 1 !important; z-index: 99999 !important; position: fixed !important; top: 0 !important; left: 0 !important; width: 100vw !important; height: 100vh !important; min-width: 100vw !important; min-height: 100vh !important; background: rgba(0,0,0,0.7) !important; justify-content: center !important; align-items: center !important; overflow: auto !important;';
                        }
                    }
                }, 50);
            } else {
                console.log('[openConfigModal] Modal confirmed visible after 100ms');
            }
        }, 100);
    } catch (error) {
        console.error('[openConfigModal] ERROR:', error);
        alert('Error opening configuration modal: ' + error.message);
    }
}

/**
 * ?? Load employees without payroll configuration
 * Uses GetEmployeesWithoutConfig WebMethod from Payroll.aspx.cs
 * Fetches from Employees table (no document creation)
 */
function loadEmployeesForConfigModal() {
    console.log('========================================');
    console.log('?? Loading employees WITHOUT config for modal...');
    console.log('========================================');
    
    const select = document.getElementById('configEmployeeId');
    select.innerHTML = '<option value="">-- Loading... --</option>';
    select.disabled = true;
    
    $.ajax({
        type: 'POST',
        url: 'Payroll.aspx/GetEmployeesWithoutConfig', // ? CORRECT: WebMethod in Payroll.aspx.cs
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        timeout: 30000, // 30-second timeout
        success: function(response) {
            console.log('?? Raw server response:', response);
            try {
                // Parse response (handle both direct object and stringified JSON)
                const result = typeof response.d === 'string' ? JSON.parse(response.d) : response.d;
                console.log('?? Parsed result:', result);
                
                // Check if request was successful
                if (!result.success) {
                    console.error('? Server returned error:', result.message);
                    select.innerHTML = '<option value="">-- ' + (result.message || 'Error loading employees') + ' --</option>';
                    select.disabled = false;
                    return;
                }
                
                const employees = result.data || [];
                console.log(`? Received ${employees.length} employees WITHOUT payroll config`);
                
                // Clear dropdown
                select.innerHTML = '<option value="">-- Select Employee --</option>';
                
                if (employees.length === 0) {
                    select.innerHTML = '<option value="">-- No unconfigured employees found --</option>';
                    console.log('?? All employees already have payroll configurations OR no employees exist');
                } else {
                    employees.forEach((emp, index) => {
                        const option = document.createElement('option');
                        option.value = emp.employeeId; // MongoDB ObjectId from Employee.Id
                        option.textContent = `${emp.employeeNumber} - ${emp.fullName} (${emp.department})`;
                        option.dataset.employeeName = emp.fullName;
                        option.dataset.employeeNumber = emp.employeeNumber;
                        option.dataset.department = emp.department;
                        option.dataset.role = emp.role;
                        select.appendChild(option);
                        
                        if (index < 3) {
                            console.log(`  ?? Employee ${index + 1}:`, {
                                id: emp.employeeId,
                                number: emp.employeeNumber,
                                name: emp.fullName,
                                dept: emp.department
                            });
                        }
                    });
                    console.log(`? Dropdown populated with ${employees.length} unconfigured employees`);
                }
                select.disabled = false;
            } catch (parseError) {
                console.error('? Error parsing response:', parseError);
                console.error('Response.d:', response.d);
                select.innerHTML = '<option value="">-- Error parsing server response --</option>';
                select.disabled = false;
            }
        },
        error: function(xhr, status, error) {
            console.error('========================================');
            console.error('? AJAX error loading employees:', {
                status: status,
                error: error,
                statusText: xhr.statusText,
                responseText: xhr.responseText ? xhr.responseText.substring(0, 500) : 'N/A'
            });
            console.error('========================================');
            
            let errorMessage = '-- Error loading employees --';
            
            if (status === 'timeout') {
                errorMessage = '-- Timeout: Check MongoDB connection --';
                console.error('?? Request timed out after 30 seconds');
            } else if (xhr.status === 500) {
                errorMessage = '-- Server error (check debug logs) --';
                console.error('?? Server returned 500 error');
            } else if (xhr.status === 0) {
                errorMessage = '-- Network error --';
                console.error('?? Network error or CORS issue');
            }
            
            select.innerHTML = `<option value="">${errorMessage}</option>`;
            select.disabled = false;
        }
    });
}

/**
 * ?? Populate employee details and auto-calculate salary
 */
function populateEmployeeDetails() {
    const select = document.getElementById('configEmployeeId');
    const selectedOption = select.options[select.selectedIndex];
    
    if (!selectedOption || !selectedOption.value) {
        // Clear form if no selection
        resetConfigForm();
        return;
    }
    
    const employeeName = selectedOption.dataset.employeeName;
    const employeeNumber = selectedOption.dataset.employeeNumber;
    const department = selectedOption.dataset.department;
    const role = selectedOption.dataset.role;
    
    console.log('?? Selected employee:', employeeName, department, role);
    
    // Auto-calculate salary based on department
    const salarySetup = getDefaultSalaryByDepartment(department, role);
    
    // Populate salary fields
    document.getElementById('configBasicSalary').value = salarySetup.basicSalary.toFixed(2);
    document.getElementById('configHousingAllowance').value = salarySetup.housingAllowance.toFixed(2);
    document.getElementById('configTransportAllowance').value = salarySetup.transportAllowance.toFixed(2);
    document.getElementById('configMealAllowance').value = salarySetup.mealAllowance.toFixed(2);
    document.getElementById('configOtherAllowances').value = '0.00';
    
    // Populate statutory deductions
    document.getElementById('configSSSContribution').value = salarySetup.sssContribution.toFixed(2);
    document.getElementById('configPhilHealthContribution').value = salarySetup.philHealthContribution.toFixed(2);
    document.getElementById('configPagIbigContribution').value = '100.00'; // Fixed
    document.getElementById('configWithholdingTax').value = salarySetup.withholdingTax.toFixed(2);
    
    // Clear loan deductions
    document.getElementById('configSSSLoan').value = '0.00';
    document.getElementById('configPagIbigLoan').value = '0.00';
    document.getElementById('configCompanyLoan').value = '0.00';
    document.getElementById('configOtherDeductions').value = '0.00';
    
    // Populate penalty rates
    document.getElementById('configAbsencePenaltyRate').value = '500.00';
    document.getElementById('configLatePenaltyRate').value = '100.00';
    
    // Populate overtime rates
    document.getElementById('configRegularOvertimeRate').value = salarySetup.overtimeRate.toFixed(2);
    document.getElementById('configHolidayOvertimeRate').value = (salarySetup.overtimeRate * 1.5).toFixed(2);
    document.getElementById('configNightDifferentialRate').value = (salarySetup.overtimeRate * 0.8).toFixed(2);
    
    // Calculate totals
    calculateTotals();
    
    console.log('? Salary auto-populated for', department);
}

/**
 * ?? Get default salary by department (matches Recruitment.aspx.cs logic)
 */
function getDefaultSalaryByDepartment(department, role) {
    let basicSalary = 25000;
    let housingAllowance = 4000;
    let transportAllowance = 1500;
    let mealAllowance = 1000;
    let overtimeRate = 125;
    let sssContribution = 1100;
    let philHealthContribution = 800;
    let withholdingTax = 2100;
    
    // Adjust by department
    const dept = (department || '').toLowerCase();
    
    if (dept.includes('it') || dept.includes('information technology')) {
        basicSalary = 35000;
        housingAllowance = 6000;
        transportAllowance = 2500;
        mealAllowance = 1500;
        overtimeRate = 175;
        sssContribution = 1350;
        philHealthContribution = 1000;
        withholdingTax = 3000;
    } else if (dept.includes('research') || dept.includes('development')) {
        basicSalary = 32000;
        housingAllowance = 5500;
        transportAllowance = 2200;
        mealAllowance = 1200;
        overtimeRate = 160;
        sssContribution = 1300;
        philHealthContribution = 950;
        withholdingTax = 2800;
    } else if (dept.includes('quality')) {
        basicSalary = 28000;
        housingAllowance = 4500;
        transportAllowance = 1800;
        mealAllowance = 1000;
        overtimeRate = 140;
        sssContribution = 1150;
        philHealthContribution = 850;
        withholdingTax = 2300;
    } else if (dept.includes('finance') || dept.includes('accounting')) {
        basicSalary = 30000;
        housingAllowance = 5000;
        transportAllowance = 2000;
        mealAllowance = 1000;
        overtimeRate = 150;
        sssContribution = 1200;
        philHealthContribution = 900;
        withholdingTax = 2500;
    } else if (dept.includes('hr') || dept.includes('human')) {
        basicSalary = 28000;
        housingAllowance = 4500;
        transportAllowance = 1800;
        mealAllowance = 1000;
        overtimeRate = 140;
        sssContribution = 1150;
        philHealthContribution = 850;
        withholdingTax = 2300;
    } else if (dept.includes('marketing')) {
        basicSalary = 27000;
        housingAllowance = 4200;
        transportAllowance = 2000;
        mealAllowance = 1000;
        overtimeRate = 135;
        sssContribution = 1120;
        philHealthContribution = 820;
        withholdingTax = 2200;
    }
    
    // Adjust for senior roles
    const roleText = (role || '').toLowerCase();
    if (roleText.includes('senior') || roleText.includes('lead') || roleText.includes('manager')) {
        basicSalary *= 1.3;
        housingAllowance *= 1.2;
        transportAllowance *= 1.2;
        overtimeRate *= 1.3;
        sssContribution *= 1.15;
        philHealthContribution *= 1.15;
        withholdingTax *= 1.3;
    }
    
    return {
        basicSalary,
        housingAllowance,
        transportAllowance,
        mealAllowance,
        overtimeRate,
        sssContribution,
        philHealthContribution,
        withholdingTax
    };
}

/**
 * ?? Calculate totals in real-time
 */
function calculateTotals() {
    // Get values
    const basicSalary = parseFloat(document.getElementById('configBasicSalary').value) || 0;
    const housingAllowance = parseFloat(document.getElementById('configHousingAllowance').value) || 0;
    const transportAllowance = parseFloat(document.getElementById('configTransportAllowance').value) || 0;
    const mealAllowance = parseFloat(document.getElementById('configMealAllowance').value) || 0;
    const otherAllowances = parseFloat(document.getElementById('configOtherAllowances').value) || 0;
    
    const sss = parseFloat(document.getElementById('configSSSContribution').value) || 0;
    const philHealth = parseFloat(document.getElementById('configPhilHealthContribution').value) || 0;
    const pagIbig = parseFloat(document.getElementById('configPagIbigContribution').value) || 0;
    const tax = parseFloat(document.getElementById('configWithholdingTax').value) || 0;
    
    const sssLoan = parseFloat(document.getElementById('configSSSLoan').value) || 0;
    const pagIbigLoan = parseFloat(document.getElementById('configPagIbigLoan').value) || 0;
    const companyLoan = parseFloat(document.getElementById('configCompanyLoan').value) || 0;
    
    // Calculate totals
    const totalAllowances = housingAllowance + transportAllowance + mealAllowance + otherAllowances;
    const grossMonthlySalary = basicSalary + totalAllowances;
    
    const totalStatutory = sss + philHealth + pagIbig + tax;
    const totalLoans = sssLoan + pagIbigLoan + companyLoan;
    
    // Update displays
    document.getElementById('totalAllowancesDisplay').textContent = '\u20B1' + totalAllowances.toLocaleString('en-PH', {minimumFractionDigits: 2});
    document.getElementById('grossMonthlySalaryDisplay').textContent = '\u20B1' + grossMonthlySalary.toLocaleString('en-PH', {minimumFractionDigits: 2});
    document.getElementById('totalStatutoryDeductionsDisplay').textContent = '\u20B1' + totalStatutory.toLocaleString('en-PH', {minimumFractionDigits: 2});
    document.getElementById('totalLoanDeductionsDisplay').textContent = '\u20B1' + totalLoans.toLocaleString('en-PH', {minimumFractionDigits: 2});
}

/**
 * ?? Switch configuration section tabs
 */
function switchConfigSection(section) {
    console.log('Switching to section:', section);
    
    // Hide all sections
    document.querySelectorAll('.config-section').forEach(el => el.style.display = 'none');
    
    // Remove active class from all buttons
    document.querySelectorAll('.config-tab-btn').forEach(btn => btn.classList.remove('active'));
    
    // Show selected section
    document.getElementById('config-section-' + section).style.display = 'block';
    
    // Add active class to clicked button
    document.querySelector('.config-tab-btn[data-section="' + section + '"]').classList.add('active');
}

/**
 * ?? Save Payroll Configuration
 */
function savePayrollConfiguration() {
    console.log('?? Saving payroll configuration...');
    
    // Collect data
    const select = document.getElementById('configEmployeeId');
    const selectedOption = select.options[select.selectedIndex];
    
    const configData = {
        id: __currentConfigId,
        employeeId: __currentConfigMode === 'create' ? selectedOption.value : null,
        employeeName: __currentConfigMode === 'create' ? selectedOption.dataset.employeeName : document.getElementById('displayEmployeeName').textContent,
        employeeNumber: __currentConfigMode === 'create' ? selectedOption.dataset.employeeNumber : document.getElementById('displayEmployeeNumber').textContent,
        department: __currentConfigMode === 'create' ? selectedOption.dataset.department : document.getElementById('displayDepartment').textContent,
        basicSalary: parseFloat(document.getElementById('configBasicSalary').value) || 0,
        housingAllowance: parseFloat(document.getElementById('configHousingAllowance').value) || 0,
        transportAllowance: parseFloat(document.getElementById('configTransportAllowance').value) || 0,
        mealAllowance: parseFloat(document.getElementById('configMealAllowance').value) || 0,
        otherAllowances: parseFloat(document.getElementById('configOtherAllowances').value) || 0,
        sssContribution: parseFloat(document.getElementById('configSSSContribution').value) || 0,
        philHealthContribution: parseFloat(document.getElementById('configPhilHealthContribution').value) || 0,
        pagIbigContribution: parseFloat(document.getElementById('configPagIbigContribution').value) || 0,
        withholdingTax: parseFloat(document.getElementById('configWithholdingTax').value) || 0,
        sssLoan: parseFloat(document.getElementById('configSSSLoan').value) || 0,
        pagIbigLoan: parseFloat(document.getElementById('configPagIbigLoan').value) || 0,
        companyLoan: parseFloat(document.getElementById('configCompanyLoan').value) || 0,
        otherDeductions: parseFloat(document.getElementById('configOtherDeductions').value) || 0,
        absencePenaltyRate: parseFloat(document.getElementById('configAbsencePenaltyRate').value) || 0,
        latePenaltyRate: parseFloat(document.getElementById('configLatePenaltyRate').value) || 0,
        regularOvertimeRate: parseFloat(document.getElementById('configRegularOvertimeRate').value) || 0,
        holidayOvertimeRate: parseFloat(document.getElementById('configHolidayOvertimeRate').value) || 0,
        nightDifferentialRate: parseFloat(document.getElementById('configNightDifferentialRate').value) || 0,
        effectiveDate: document.getElementById('configEffectiveDate').value
    };
    
    // Validate
    if (__currentConfigMode === 'create' && !configData.employeeId) {
        alert('? Please select an employee');
        return;
    }
    if (!configData.basicSalary || configData.basicSalary <= 0) {
        alert('? Please enter a valid basic salary');
        return;
    }
    if (!configData.effectiveDate) {
        alert('? Please select an effective date');
        return;
    }
    
    console.log('?? Sending configuration to server:', configData);
    
    // Show loading
    const saveBtn = event.target;
    const originalText = saveBtn.textContent;
    saveBtn.textContent = 'Saving...';
    saveBtn.disabled = true;
    
    // Save via AJAX
    $.ajax({
        type: 'POST',
        url: 'Payroll.aspx/SavePayrollConfiguration',
        data: JSON.stringify({ config: configData }),
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        timeout: 45000, // 45-second timeout
        success: function(response) {
            const result = typeof response.d === 'string' ? JSON.parse(response.d) : response.d;
            
            console.log('?? Server response:', result);
            
            if (result.success) {
                alert('? Configuration saved successfully!');
                closeModal();
                loadPayrollConfigurations(); // Reload the table
            } else {
                alert('? Failed to save: ' + (result.message || 'Unknown error'));
                saveBtn.textContent = originalText;
                saveBtn.disabled = false;
            }
        },
        error: function(xhr, status, error) {
            console.error('? AJAX error:', error, status);
            
            if (status === 'timeout') {
                alert('?? Save operation timed out after 45 seconds.\n\nThis usually means MongoDB is slow or unreachable.\n\nPlease check:\n� MongoDB Atlas is running\n� IP whitelist is correct\n� Network connectivity');
            } else {
                alert('? Error saving configuration: ' + error + '\n\nCheck console for details.');
            }
            
            saveBtn.textContent = originalText;
            saveBtn.disabled = false;
        }
    });
}

/**
 * ?? Load all payroll configurations and display in table
 */
function loadPayrollConfigurations() {
    console.log('========================================');
    console.log('?? Loading payroll configurations...');
    console.log('========================================');
    
    const loadingState = document.getElementById('configLoadingState');
    const errorState = document.getElementById('configErrorState');
    const tableContainer = document.getElementById('configTableContainer');
    const emptyState = document.getElementById('configEmptyState');
    
    // Show loading
    loadingState.style.display = 'block';
    errorState.style.display = 'none';
    tableContainer.style.display = 'none';
    
    $.ajax({
        type: 'POST',
        url: 'Payroll.aspx/GetPayrollConfigurations',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        timeout: 30000,
        success: function(response) {
            console.log('?? Raw response:', response);
            
            try {
                const result = typeof response.d === 'string' ? JSON.parse(response.d) : response.d;
                console.log('?? Parsed configurations:', result);
                
                if (result.success && result.data) {
                    const configs = result.data;
                    console.log(`? Loaded ${configs.length} configurations`);
                    
                    if (configs.length === 0) {
                        loadingState.style.display = 'none';
                        emptyState.style.display = 'block';
                    } else {
                        renderConfigurationsTable(configs);
                        loadingState.style.display = 'none';
                        tableContainer.style.display = 'block';
                    }
                } else {
                    console.error('? Failed to load configs:', result.message);
                    showConfigError(result.message || 'Failed to load configurations');
                }
            } catch (parseError) {
                console.error('? Parse error:', parseError);
                showConfigError('Error parsing server response');
            }
        },
        error: function(xhr, status, error) {
            console.error('? AJAX error:', { status, error });
            showConfigError('Failed to connect to server: ' + error);
        }
    });
}

/**
 * ?? Render configurations in table
 */
function renderConfigurationsTable(configs) {
    const tbody = document.getElementById('configTableBody');
    tbody.innerHTML = '';
    
    configs.forEach(config => {
        const row = document.createElement('tr');
        
        const grossSalary = (config.basicSalary || 0) + 
                           (config.housingAllowance || 0) + 
                           (config.transportAllowance || 0) + 
                           (config.mealAllowance || 0) + 
                           (config.otherAllowances || 0);
        
        const totalAllowances = (config.housingAllowance || 0) + 
                               (config.transportAllowance || 0) + 
                               (config.mealAllowance || 0) + 
                               (config.otherAllowances || 0);
        
        const totalStatutory = (config.sssContribution || 0) + 
                              (config.philHealthContribution || 0) + 
                              (config.pagIbigContribution || 0) + 
                              (config.withholdingTax || 0);
        
        const totalLoans = (config.sssLoan || 0) + 
                          (config.pagIbigLoan || 0) + 
                          (config.companyLoan || 0);
        
        row.innerHTML = `
            <td>${config.employeeNumber || 'N/A'}</td>
            <td>${config.employeeName || 'N/A'}</td>
            <td>${config.department || 'N/A'}</td>
            <td class="amount-green">\u20B1${(config.basicSalary || 0).toLocaleString('en-PH', {minimumFractionDigits: 2})}</td>
            <td class="amount-blue">\u20B1${totalAllowances.toLocaleString('en-PH', {minimumFractionDigits: 2})}</td>
            <td class="amount-green" style="font-weight:700;">\u20B1${grossSalary.toLocaleString('en-PH', {minimumFractionDigits: 2})}</td>
            <td class="amount-gray">\u20B1${totalStatutory.toLocaleString('en-PH', {minimumFractionDigits: 2})}</td>
            <td class="amount-gray">\u20B1${totalLoans.toLocaleString('en-PH', {minimumFractionDigits: 2})}</td>
            <td>${config.effectiveDate ? new Date(config.effectiveDate).toLocaleDateString() : 'N/A'}</td>
            <td><span class="status-badge" style="background:#D1FAE5;color:#065F46;">${config.isActive ? 'Active' : 'Inactive'}</span></td>
            <td>
                <button type="button" class="btn-icon-sm" title="Edit" onclick="openConfigModal('edit', '${config.id}')">
                    <svg class="svg-icon-sm" viewBox="0 0 24 24" fill="currentColor">
                        <path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/>
                    </svg>
                </button>
                <button type="button" class="btn-icon-sm" title="Deactivate" onclick="deactivateConfig('${config.id}')">
                    <svg class="svg-icon-sm" viewBox="0 0 24 24" fill="currentColor">
                        <path d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/>
                    </svg>
                </button>
            </td>
        `;
        
        tbody.appendChild(row);
    });
    
    console.log(`? Rendered ${configs.length} configurations in table`);
}

/**
 * ? Show configuration error
 */
function showConfigError(message) {
    const loadingState = document.getElementById('configLoadingState');
    const errorState = document.getElementById('configErrorState');
    const errorMessage = document.getElementById('configErrorMessage');
    
    loadingState.style.display = 'none';
    errorState.style.display = 'block';
    errorMessage.textContent = message;
}

/**
 * ?? Filter configurations table
 */
function filterConfigurations() {
    const searchTerm = document.getElementById('searchConfig')?.value.toLowerCase() || '';
    const deptFilter = document.getElementById('filterConfigDept')?.value || '';
    
    const rows = document.querySelectorAll('#configTableBody tr');
    
    rows.forEach(row => {
        const name = row.cells[1]?.textContent.toLowerCase() || '';
        const empNo = row.cells[0]?.textContent.toLowerCase() || '';
        const dept = row.cells[2]?.textContent || '';
        
        const matchesSearch = !searchTerm || name.includes(searchTerm) || empNo.includes(searchTerm);
        const matchesDept = !deptFilter || dept === deptFilter;
        
        row.style.display = (matchesSearch && matchesDept) ? '' : 'none';
    });
}

/**
 * ??? Deactivate configuration
 */
function deactivateConfig(configId) {
    if (!confirm('Are you sure you want to deactivate this payroll configuration?')) {
        return;
    }
    
    $.ajax({
        type: 'POST',
        url: 'Payroll.aspx/DeactivateConfiguration',
        data: JSON.stringify({ configId: configId }),
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function(response) {
            const result = typeof response.d === 'string' ? JSON.parse(response.d) : response.d;
            if (result.success) {
                alert('? Configuration deactivated successfully');
                loadPayrollConfigurations();
            } else {
                alert('? Failed: ' + result.message);
            }
        },
        error: function() {
            alert('? Error deactivating configuration');
        }
    });
}

/**
 * ?? Export configurations to CSV
 */
function exportConfigurationsCSV() {
    alert('CSV export feature coming soon!');
}

/**
 * ??? Reset configuration form
 */
function resetConfigForm() {
    // Reset all input fields
    document.querySelectorAll('#configModal input[type="number"]').forEach(input => {
        input.value = '0.00';
    });
    document.querySelectorAll('#configModal input[type="date"]').forEach(input => {
        input.value = '';
    });
    document.getElementById('configEmployeeId').selectedIndex = 0;
    
    // Reset totals
    document.getElementById('totalAllowancesDisplay').textContent = '\u20B10.00';
    document.getElementById('grossMonthlySalaryDisplay').textContent = '\u20B10.00';
    document.getElementById('totalStatutoryDeductionsDisplay').textContent = '\u20B10.00';
    document.getElementById('totalLoanDeductionsDisplay').textContent = '\u20B10.00';
    
    // Show first section
    switchConfigSection('salary');
}

/**
 * ? Close modal (generic)
 */
function closeModal() {
    const modal = document.getElementById('configModal');
    if (modal) {
        modal.style.display = 'none';
    }
    
    // Also close other modals if they have the same ID pattern
    const payslipModal = document.getElementById('payslipModal');
    if (payslipModal) payslipModal.style.display = 'none';
    
    const summaryModal = document.getElementById('summaryModal');
    if (summaryModal) summaryModal.style.display = 'none';
}

// Explicitly expose functions to global scope
window.openConfigModal = openConfigModal;
window.closeModal = closeModal;
window.loadPayrollConfigurations = loadPayrollConfigurations;
window.savePayrollConfiguration = savePayrollConfiguration;
window.deletePayrollConfiguration = deletePayrollConfiguration;
window.filterConfigurations = filterConfigurations;
window.exportConfigurationsCSV = exportConfigurationsCSV;

console.log('? Payroll Configuration handlers loaded');
