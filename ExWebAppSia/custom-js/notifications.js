/* Notification System - Self-contained, no dependencies */
(function () {
    'use strict';

    function init() {
        var btn = document.getElementById('notificationBtn');
        var dropdownTemplate = document.getElementById('notificationDropdown');
        var badge = document.getElementById('unreadBadge');
        var markAll = document.getElementById('markAllRead');

        if (!btn || !dropdownTemplate) {
            console.warn('[Notifications] Missing elements, aborting.');
            return;
        }

        // ---- Move the dropdown to <body> to escape all stacking contexts ----
        var dropdown = dropdownTemplate;
        document.body.appendChild(dropdown);

        // Styling for Light Theme to match "Essentials Beauty HR"
        const THEME = {
            bg: '#FFFFFF',
            headerBg: '#FFFFFF',
            footerBg: '#FAFAFA',
            border: '#F0EEEE',
            textPrimary: '#4A3534',
            textSecondary: '#9B7D7B',
            accent: '#A44F56',
            hover: '#F8ECEB',
            shadow: '0 12px 40px rgba(163, 106, 102, 0.2)'
        };

        // Override ALL inherited styles with our own via inline style
        dropdown.setAttribute('style', [
            'position: fixed',
            'width: 360px',
            'background: ' + THEME.bg,
            'color: ' + THEME.textPrimary,
            'border-radius: 16px',
            'box-shadow: ' + THEME.shadow,
            'z-index: 2147483647',
            'display: none',
            'border: 1px solid ' + THEME.border,
            'overflow: hidden',
            'font-family: inherit'
        ].join('; '));

        var list = document.getElementById('notificationList');

        function positionDropdown() {
            var rect = btn.getBoundingClientRect();
            var top = rect.bottom + 12;
            var left = rect.right - 360;
            if (left < 12) left = 12;
            dropdown.style.top = top + 'px';
            dropdown.style.left = left + 'px';
        }

        var isOpen = false;

        btn.addEventListener('click', function (e) {
            e.stopPropagation();
            e.preventDefault();
            if (isOpen) {
                closeDropdown();
            } else {
                openDropdown();
            }
        });

        function openDropdown() {
            positionDropdown();
            dropdown.style.display = 'block';
            isOpen = true;
            fetchNotifications();
        }

        function closeDropdown() {
            dropdown.style.display = 'none';
            isOpen = false;
        }

        document.addEventListener('click', function (e) {
            if (isOpen && !dropdown.contains(e.target) && !btn.contains(e.target)) {
                closeDropdown();
            }
        });

        window.addEventListener('resize', function () {
            if (isOpen) positionDropdown();
        });

        window.addEventListener('scroll', function () {
            if (isOpen) positionDropdown();
        }, true);

        if (markAll) {
            markAll.setAttribute('style', 'font-size:12px; color:' + THEME.textSecondary + '; background:none; border:none; cursor:pointer; padding:0;');
            markAll.addEventListener('mouseover', function() { this.style.color = THEME.accent; });
            markAll.addEventListener('mouseout', function() { this.style.color = THEME.textSecondary; });
            
            markAll.addEventListener('click', function (e) {
                e.preventDefault();
                e.stopPropagation();
                doXhr('POST', '/Handler/NotificationHandler.ashx?action=readAll', null, function () {
                    fetchNotifications();
                });
            });
        }

        // Style the header & footer templates
        const header = dropdown.querySelector('.notification-header');
        if (header) {
            header.setAttribute('style', 'padding:20px; background:' + THEME.headerBg + '; border-bottom:1px solid ' + THEME.border + '; display:flex; justify-content:space-between; align-items:center;');
            const h3 = header.querySelector('h3');
            if (h3) h3.setAttribute('style', 'margin:0; font-size:16px; font-weight:700; color:' + THEME.textPrimary + ';');
        }

        const footer = dropdown.querySelector('.notification-footer');
        if (footer) {
            footer.setAttribute('style', 'padding:16px 20px; text-align:center; background:' + THEME.footerBg + '; border-top:1px solid ' + THEME.border + ';');
            const viewAll = footer.querySelector('a');
            if (viewAll) viewAll.setAttribute('style', 'font-size:13px; font-weight:600; color:' + THEME.accent + '; text-decoration:none;');
        }

        function doXhr(method, url, body, cb) {
            var xhr = new XMLHttpRequest();
            xhr.open(method, url, true);
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4) {
                    if (xhr.status >= 200 && xhr.status < 300) {
                        try { cb(JSON.parse(xhr.responseText)); } catch (e) { cb({}); }
                    } else {
                        console.error('[Notifications] XHR error:', xhr.status);
                    }
                }
            };
            if (body) {
                xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
                xhr.send(body);
            } else {
                xhr.send();
            }
        }

        function fetchNotifications() {
            doXhr('GET', '/Handler/NotificationHandler.ashx?action=get', null, function (data) {
                if (data && data.success) {
                    renderBadge(data.unreadCount || 0);
                    renderList(data.notifications || []);
                }
            });
        }

        function renderBadge(count) {
            if (!badge) return;
            if (count > 0) {
                badge.textContent = count > 9 ? '9+' : count;
                badge.style.cssText = 'display:flex; position:absolute; top:-4px; right:-4px; background:linear-gradient(135deg, #EF4444, #DC2626); color:white; font-size:10px; font-weight:700; padding:2px 6px; border-radius:10px; min-width:18px; text-align:center; box-shadow: 0 2px 8px rgba(239, 68, 68, 0.4); z-index: 10;';
            } else {
                badge.style.display = 'none';
            }
        }

        function renderList(notifications) {
            if (!list) return;
            list.setAttribute('style', 'max-height:400px; overflow-y:auto; background:' + THEME.bg + ';');
            
            if (!notifications.length) {
                list.innerHTML = '<div style="padding:60px 20px;text-align:center;color:' + THEME.textSecondary + ';">' +
                    '<i class="far fa-bell-slash" style="font-size:32px;display:block;margin-bottom:15px; opacity:0.5;"></i>' +
                    '<p style="margin:0;font-size:14px;">No notifications yet</p></div>';
                return;
            }

            var html = '';
            for (var i = 0; i < notifications.length; i++) {
                var n = notifications[i];
                var iconColor = THEME.accent;
                var icon = 'fa-bell';
                if (n.Type === 'Announcement') { iconColor = '#3182CE'; icon = 'fa-bullhorn'; }
                else if (n.Type === 'NewRequest') { iconColor = '#38A169'; icon = 'fa-file-invoice'; }
                else if (n.Type === 'RequestUpdate') { iconColor = THEME.accent; icon = 'fa-check-circle'; }

                var bgStyle = n.IsRead ? '' : 'background:linear-gradient(90deg, ' + THEME.hover + ' 0%, transparent 100%); border-left:4px solid ' + THEME.accent + ';';
                var time = formatTime(n.Timestamp);

                // Build safe link
                var link = n.Link || '#';
                if (link.indexOf('~/') === 0) {
                    link = window.location.origin + '/' + link.substring(2);
                }

                html += '<a href="' + link + '" data-id="' + (n.Id || '') + '" ' +
                    'class="notif-item-link" ' +
                    'style="display:flex;gap:16px;padding:16px 20px;text-decoration:none;color:inherit;border-bottom:1px solid ' + THEME.border + ';align-items:flex-start;transition:all 0.2s;' + bgStyle + '">' +
                    '<div style="width:40px;height:40px;border-radius:12px;display:flex;align-items:center;justify-content:center;flex-shrink:0;background:' + THEME.hover + ';color:' + iconColor + ';font-size:16px;">' +
                    '<i class="fas ' + icon + '"></i></div>' +
                    '<div style="flex:1;min-width:0;">' +
                    '<div style="font-size:14px;font-weight:600;color:' + THEME.textPrimary + ';margin-bottom:4px;">' + escHtml(n.Title) + '</div>' +
                    '<div style="font-size:13px;color:' + THEME.textSecondary + ';line-height:1.5;margin-bottom:6px;">' + escHtml(n.Message) + '</div>' +
                    '<span style="font-size:11px;color:' + THEME.textSecondary + '; opacity:0.8;">' + time + '</span>' +
                    '</div></a>';
            }
            list.innerHTML = html;

            // Mark as read on click
            var items = list.querySelectorAll('.notif-item-link');
            for (var j = 0; j < items.length; j++) {
                items[j].addEventListener('click', function () {
                    var id = this.getAttribute('data-id');
                    if (id) doXhr('POST', '/Handler/NotificationHandler.ashx?action=read', 'id=' + id, function () { });
                });
                // Simple hover effect
                items[j].addEventListener('mouseover', function() { this.style.backgroundColor = THEME.hover; });
                items[j].addEventListener('mouseout', function() { 
                    const isUnread = this.style.borderLeftWidth === '4px';
                    this.style.backgroundColor = isUnread ? '' : 'transparent'; 
                });
            }
        }

        function formatTime(ts) {
            if (!ts) return '';
            var d = new Date(ts);
            if (isNaN(d.getTime())) return '';
            var diff = Math.floor((Date.now() - d) / 1000);
            if (diff < 60) return 'Just now';
            if (diff < 3600) return Math.floor(diff / 60) + 'm ago';
            if (diff < 86400) return Math.floor(diff / 3600) + 'h ago';
            if (diff < 604800) return Math.floor(diff / 86400) + 'd ago';
            return d.toLocaleDateString();
        }

        function escHtml(s) {
            if (!s) return '';
            return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
        }

        // Initial badge fetch
        fetchNotifications();
        setInterval(fetchNotifications, 30000);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
