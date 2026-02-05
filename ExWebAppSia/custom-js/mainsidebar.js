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
        // Load notifications when dropdown is opened
        if (notificationDropdown.classList.contains('show')) {
            loadNotifications();
        }
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

    // ========== GLOBAL SEARCH FUNCTIONALITY ==========
    const globalSearch = document.getElementById('globalSearch');
    const searchResults = document.getElementById('searchResults');
    const searchClear = document.getElementById('searchClear');

    // Define searchable pages/sections
    const searchableItems = [
        { name: 'Dashboard', url: 'Dashboard.aspx', keywords: ['dashboard', 'home', 'overview', 'statistics', 'summary'] },
        { name: 'Employees', url: 'Employee.aspx', keywords: ['employee', 'staff', 'workers', 'personnel', 'team', 'department'] },
        { name: 'Attendance', url: 'Attendance.aspx', keywords: ['attendance', 'time', 'clock', 'present', 'absent', 'late', 'timein', 'timeout'] },
        { name: 'Announcements', url: 'Announcement.aspx', keywords: ['announcement', 'news', 'post', 'notice', 'bulletin', 'communication'] },
        { name: 'Recruitment', url: 'Recruitment.aspx', keywords: ['recruitment', 'hiring', 'applicant', 'candidate', 'job', 'position', 'interview'] },
        { name: 'Payroll', url: 'Payroll.aspx', keywords: ['payroll', 'salary', 'wage', 'payment', 'compensation', 'deduction', 'payslip'] },
        { name: 'Payroll Configuration', url: 'Payroll.aspx#configuration', keywords: ['payroll config', 'salary setup', 'allowance', 'deduction setup'] },
        { name: 'Payroll Generation', url: 'Payroll.aspx#payroll-gen', keywords: ['generate payroll', 'compute salary', 'payroll run'] },
        { name: 'Payslips', url: 'Payroll.aspx#payslips', keywords: ['payslip', 'pay stub', 'salary slip'] },
        { name: 'Payroll History', url: 'Payroll.aspx#history', keywords: ['payroll history', 'past payroll', 'previous payroll'] },
        { name: 'Leave Requests', url: 'Employee.aspx#leave', keywords: ['leave', 'vacation', 'sick leave', 'absence', 'time off', 'pto'] }
    ];

    if (globalSearch) {
        globalSearch.addEventListener('input', function () {
            const query = this.value.toLowerCase().trim();
            
            if (searchClear) {
                searchClear.style.display = query.length > 0 ? 'block' : 'none';
            }

            if (query.length < 2) {
                if (searchResults) searchResults.style.display = 'none';
                return;
            }

            // Filter searchable items
            const results = searchableItems.filter(item => {
                const nameMatch = item.name.toLowerCase().includes(query);
                const keywordMatch = item.keywords.some(keyword => keyword.includes(query));
                return nameMatch || keywordMatch;
            });

            // Display results
            if (results.length > 0 && searchResults) {
                searchResults.innerHTML = results.map(item => `
                    <div class="search-result-item" onclick="window.location.href='${item.url}'">
                        <i class="fas fa-search"></i>
                        <span>${item.name}</span>
                    </div>
                `).join('');
                searchResults.style.display = 'block';
            } else if (searchResults) {
                searchResults.innerHTML = '<div class="search-result-item no-results">No results found</div>';
                searchResults.style.display = 'block';
            }
        });

        globalSearch.addEventListener('keypress', function (e) {
            if (e.key === 'Enter') {
                const query = this.value.toLowerCase().trim();
                if (query.length >= 2) {
                    // Navigate to the first matching result
                    const results = searchableItems.filter(item => {
                        const nameMatch = item.name.toLowerCase().includes(query);
                        const keywordMatch = item.keywords.some(keyword => keyword.includes(query));
                        return nameMatch || keywordMatch;
                    });
                    if (results.length > 0) {
                        window.location.href = results[0].url;
                    }
                }
            }
        });

        // Close search results when clicking outside
        document.addEventListener('click', function (e) {
            if (!e.target.closest('.search-container') && searchResults) {
                searchResults.style.display = 'none';
            }
        });
    }

    if (searchClear) {
        searchClear.addEventListener('click', function () {
            if (globalSearch) {
                globalSearch.value = '';
                globalSearch.focus();
            }
            if (searchResults) searchResults.style.display = 'none';
            this.style.display = 'none';
        });
    }

    // ========== NOTIFICATION FUNCTIONALITY ==========
    const notificationsList = document.getElementById('notificationsList');
    const notificationBadge = document.getElementById('notificationBadge');
    const markAllReadBtn = document.getElementById('markAllReadBtn');
    const viewAllNotificationsBtn = document.getElementById('viewAllNotificationsBtn');

    // Sample notifications (in real app, this would come from backend)
    let notifications = [];

    function loadNotifications() {
        // Simulated notifications - in production, this would be an API call
        notifications = [
            { id: 1, type: 'leave', message: 'Carmen Lim requested vacation leave (Nov 10-12)', time: '2 hours ago', read: false },
            { id: 2, type: 'attendance', message: '3 employees are late today', time: '3 hours ago', read: false },
            { id: 3, type: 'recruitment', message: 'New applicant: John Doe for Developer position', time: '5 hours ago', read: false },
            { id: 4, type: 'payroll', message: 'Payroll for November 2025 is ready for review', time: '1 day ago', read: true },
            { id: 5, type: 'announcement', message: 'New company policy posted', time: '2 days ago', read: true }
        ];

        renderNotifications();
    }

    function renderNotifications() {
        if (!notificationsList) return;

        const unreadCount = notifications.filter(n => !n.read).length;
        
        // Update badge
        if (notificationBadge) {
            if (unreadCount > 0) {
                notificationBadge.textContent = unreadCount > 9 ? '9+' : unreadCount;
                notificationBadge.style.display = 'flex';
            } else {
                notificationBadge.style.display = 'none';
            }
        }

        if (notifications.length === 0) {
            notificationsList.innerHTML = `
                <div class="notification-empty">
                    <i class="fas fa-bell-slash"></i>
                    <p>No notifications</p>
                </div>
            `;
            return;
        }

        notificationsList.innerHTML = notifications.map(notification => `
            <div class="notification-item ${notification.read ? 'read' : 'unread'}" data-id="${notification.id}">
                <div class="notification-icon ${notification.type}">
                    <i class="fas ${getNotificationIcon(notification.type)}"></i>
                </div>
                <div class="notification-content">
                    <p class="notification-message">${notification.message}</p>
                    <span class="notification-time">${notification.time}</span>
                </div>
                ${!notification.read ? '<span class="notification-dot"></span>' : ''}
            </div>
        `).join('');

        // Add click handlers to mark as read
        document.querySelectorAll('.notification-item').forEach(item => {
            item.addEventListener('click', function () {
                const id = parseInt(this.dataset.id);
                markAsRead(id);
            });
        });
    }

    function getNotificationIcon(type) {
        const icons = {
            'leave': 'fa-calendar-check',
            'attendance': 'fa-user-clock',
            'recruitment': 'fa-user-plus',
            'payroll': 'fa-money-bill-wave',
            'announcement': 'fa-bullhorn',
            'default': 'fa-bell'
        };
        return icons[type] || icons['default'];
    }

    function markAsRead(id) {
        const notification = notifications.find(n => n.id === id);
        if (notification) {
            notification.read = true;
            renderNotifications();
        }
    }

    function markAllAsRead() {
        notifications.forEach(n => n.read = true);
        renderNotifications();
    }

    if (markAllReadBtn) {
        markAllReadBtn.addEventListener('click', markAllAsRead);
    }

    if (viewAllNotificationsBtn) {
        viewAllNotificationsBtn.addEventListener('click', function () {
            // Navigate to a notifications page or show more notifications
            alert('View all notifications - This would navigate to a dedicated notifications page');
        });
    }

    // Load notifications on page load
    loadNotifications();
});