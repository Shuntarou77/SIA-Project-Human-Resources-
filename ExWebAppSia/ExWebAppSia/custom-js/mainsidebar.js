document.addEventListener('DOMContentLoaded', function () {
    console.log('DOM loaded - initializing sidebar functionality');

    // Toggle Mobile Sidebar
    document.getElementById('mobileMenuToggle')?.addEventListener('click', function () {
        document.getElementById('sidebar').classList.toggle('active');
    });

    // User Menu Dropdown
    const userMenuBtn = document.getElementById('userMenuBtn');
    const userDropdown = document.getElementById('userDropdown');

    userMenuBtn?.addEventListener('click', function (e) {
        e.stopPropagation();
        e.preventDefault();
        console.log('User menu clicked');
        userDropdown.classList.toggle('show');
    });

    // Notification Menu Dropdown
    const notificationBtn = document.getElementById('notificationBtn');
    const notificationDropdown = document.getElementById('notificationDropdown');

    notificationBtn?.addEventListener('click', function (e) {
        e.stopPropagation();
        e.preventDefault();
        notificationDropdown.classList.toggle('show');
    });

    // Close dropdowns when clicking outside
    document.addEventListener('click', function (e) {
        // Check if click is outside dropdowns and not on the buttons
        const isUserMenuClick = e.target.closest('#userMenuBtn') || e.target.closest('.user-menu-btn');
        const isNotificationClick = e.target.closest('#notificationBtn') || e.target.closest('.notification-btn');
        const isDropdownClick = e.target.closest('.dropdown-menu');

        if (!isDropdownClick && !isUserMenuClick && !isNotificationClick) {
            document.querySelectorAll('.dropdown-menu').forEach(dropdown => {
                dropdown.classList.remove('show');
            });
        }
    });

    // Prevent dropdown from closing when clicking inside
    document.querySelectorAll('.dropdown-menu').forEach(dropdown => {
        dropdown.addEventListener('click', function (e) {
            e.stopPropagation();
        });
    });

    // Logout Modal Functionality
    const logoutTriggerBtn = document.getElementById('logoutTriggerBtn');
    const logoutModalElement = document.getElementById('logoutModal');
    const confirmLogoutBtn = document.getElementById('confirmLogoutBtn');

    console.log('Logout elements:', {
        trigger: logoutTriggerBtn,
        modal: logoutModalElement,
        confirm: confirmLogoutBtn,
        bootstrap: typeof bootstrap
    });

    if (logoutTriggerBtn && logoutModalElement && confirmLogoutBtn && typeof bootstrap !== 'undefined') {
        const logoutModal = new bootstrap.Modal(logoutModalElement);
        const logoutBtnText = confirmLogoutBtn.querySelector('.btn-text');
        const logoutBtnLoading = confirmLogoutBtn.querySelector('.btn-loading');

        // Open logout modal when logout is clicked
        logoutTriggerBtn.addEventListener('click', function (e) {
            e.preventDefault();
            e.stopPropagation();
            console.log('Logout trigger clicked');
            // Close user dropdown
            userDropdown.classList.remove('show');
            // Show logout modal
            logoutModal.show();
        });

        // Handle logout confirmation
        confirmLogoutBtn.addEventListener('click', function () {
            console.log('Logout confirmed');
            // Show loading state
            logoutBtnText.style.display = 'none';
            logoutBtnLoading.style.display = 'inline-block';
            confirmLogoutBtn.disabled = true;

            // Perform logout (redirect to logout page)
            setTimeout(function () {
                window.location.href = '../LoginFolder/Login.aspx';
            }, 1000);
        });

        // Reset logout button when modal is hidden
        logoutModalElement.addEventListener('hidden.bs.modal', function () {
            logoutBtnText.style.display = 'inline-block';
            logoutBtnLoading.style.display = 'none';
            confirmLogoutBtn.disabled = false;
        });
    } else {
        console.error('Logout modal elements not found or Bootstrap not loaded');
    }

    // Active menu highlighting
    const currentPath = window.location.pathname;
    document.querySelectorAll('.nav-link').forEach(link => {
        if (link.getAttribute('href') === currentPath) {
            link.classList.add('active');
        }
    });
});