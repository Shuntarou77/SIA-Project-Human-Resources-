<%@ Page Title="Announcements" Language="C#" MasterPageFile="~/webpage(EmployeeViewpoint)/EmployeeHR.Master"
    AutoEventWireup="true" CodeBehind="Announcement.aspx.cs" Inherits="ExWebAppSia.webpage_EmployeeViewpoint_.WebForm4"
    %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <style>
            :root {
                --bg-color: #ffffff;
                /* ✅ Pure white background */
                --panel-bg: #ffffff;
                --text-dark: #333333;
                --border-color: #e8e8e8;
                --hover-bg: #f9f9f9;
                --accent: #A36A66;
                /* ✅ Unified brand color */
                --accent-light: #C49A99;
                /* Lighter tint */
                --accent-dark: #8B5A58;
                /* Darker on hover/active */
                --admin-bg: #F8ECEB;
                /* Soft warm tint (replaces #FFF5F5) */
                --admin-border: #D8BFBF;
                /* Harmonious border */
            }

            html,
            body {
                margin: 0;
                padding: 0;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background-color: var(--bg-color);
                height: 100%;
                width: 100%;
                box-sizing: border-box;
            }

            .container-box {
                width: 100%;
                min-height: 100vh;
                padding: 20px;
                background-color: var(--bg-color);
                box-sizing: border-box;
                display: flex;
                flex-direction: column;
                gap: 20px;
            }

            /* Filter Tabs — ✅ Active tab uses #A36A66 */
            .filter-tabs {
                display: flex;
                gap: 16px;
                margin-bottom: 20px;
                padding: 10px 0;
                border-bottom: 1px solid var(--border-color);
            }

            .filter-tab {
                display: flex;
                align-items: center;
                gap: 8px;
                padding: 8px 16px;
                border-radius: 20px;
                cursor: pointer;
                font-size: 14px;
                color: #777;
                transition: all 0.2s ease;
            }

            .filter-tab:hover {
                background-color: #f5f5f5;
                color: var(--accent-dark);
            }

            .filter-tab.active {
                background: linear-gradient(135deg, var(--accent), var(--accent-light));
                color: white;
                font-weight: 600;
                box-shadow: 0 2px 6px rgba(163, 106, 102, 0.2);
            }

            .filter-icon {
                width: 18px;
                height: 18px;
                fill: currentColor;
            }

            /* Announcement Cards */
            .announcement-cards {
                display: flex;
                flex-direction: column;
                gap: 16px;
            }

            .announcement-card {
                background-color: var(--panel-bg);
                border-radius: 12px;
                padding: 16px;
                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
                border: 1px solid var(--border-color);
                transition: transform 0.2s, box-shadow 0.2s;
            }

            .announcement-card:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            }

            /* Admin Card Highlight — ✅ Warmer, more elegant */
            .announcement-card.admin {
                background-color: var(--admin-bg);
                border: 1px solid var(--admin-border);
            }

            .card-header {
                display: flex;
                align-items: center;
                gap: 12px;
                margin-bottom: 12px;
            }

            .card-avatar {
                width: 40px;
                height: 40px;
                border-radius: 50%;
                overflow: hidden;
                border: 1px solid var(--border-color);
            }

            .card-avatar img {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }

            .card-info {
                flex: 1;
            }

            .card-name {
                font-weight: 600;
                color: var(--text-dark);
                font-size: 14px;
                margin: 0;
                display: flex;
                align-items: center;
                gap: 8px;
            }

            /* Admin Badge — ✅ #A36A66 */
            .admin-badge {
                background-color: var(--accent);
                color: white;
                font-size: 10px;
                padding: 2px 8px;
                border-radius: 14px;
                font-weight: bold;
                letter-spacing: 0.5px;
            }

            /* New Badge — Green for recent announcements */
            .new-badge {
                background-color: #22c55e;
                color: white;
                font-size: 10px;
                padding: 2px 8px;
                border-radius: 14px;
                font-weight: bold;
                letter-spacing: 0.5px;
            }

            /* Pinned Badge — Blue for pinned announcements */
            .pinned-badge {
                background-color: #3b82f6;
                color: white;
                font-size: 10px;
                padding: 2px 8px;
                border-radius: 14px;
                font-weight: bold;
                letter-spacing: 0.5px;
            }

            /* New announcement card highlight */
            .announcement-card.new-post {
                border-left: 4px solid #22c55e;
            }

            /* Pinned announcement card highlight */
            .announcement-card.pinned-post {
                border-left: 4px solid #3b82f6;
                background-color: #f0f9ff;
            }

            .card-role {
                font-size: 12px;
                color: #777;
                margin: 2px 0 0;
            }

            .card-time {
                font-size: 11px;
                color: #aaa;
                margin: 4px 0 0;
            }

            .card-body {
                font-size: 14px;
                color: var(--text-dark);
                line-height: 1.5;
                margin-top: 12px;
            }

            /* Video container for proper formatting */
            .video-container {
                margin-top: 12px;
                position: relative;
                width: 100%;
                max-width: 100%;
            }

            .video-container video {
                width: 100%;
                max-height: 400px;
                border-radius: 8px;
                border: 1px solid var(--border-color);
                background-color: #000;
            }

            /* Gmail button style */
            .btn-gmail {
                background-color: #f1f3f4;
                color: #d93025;
                border: 1px solid #dcdcdc;
                padding: 4px 12px;
                border-radius: 4px;
                font-size: 12px;
                font-weight: 500;
                display: flex;
                align-items: center;
                gap: 6px;
                cursor: pointer;
                transition: all 0.2s;
                margin-top: 10px;
            }

            .btn-gmail:hover {
                background-color: #e8eaed;
                border-color: #c6c6c6;
            }

            /* Responsive */
            @media (max-width: 768px) {
                .container-box {
                    padding: 12px;
                }
            }
        </style>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        <div class="container-box">
            <!-- Filter Tabs -->
            <div class="filter-tabs">
                <div class="filter-tab active" onclick="filterAnnouncements('all', event)">
                    <svg class="filter-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                        <path d="M3 13h8V3H3v10zm0 8h8v-6H3v6zm10-18h8v10h-8V3zm0 14h8v-6h-8v6z" />
                    </svg>
                    <span>All</span>
                </div>
                <div class="filter-tab" onclick="filterAnnouncements('new', event)">
                    <svg class="filter-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                        <path
                            d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-2-2 1.41-1.41L10 14.17l6.59-6.59L18 9l-8 8z" />
                    </svg>
                    <span>New</span>
                </div>
                <div class="filter-tab" onclick="filterAnnouncements('pinned', event)">
                    <svg class="filter-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                        <path d="M16 12V4H17V2H7V4H8V12L6 14V16H11.2V22H12.8V16H18V14L16 12Z" />
                    </svg>
                    <span>Pinned</span>
                </div>
            </div>

            <!-- Announcement Cards Container -->
            <div class="announcement-cards" id="announcementsContainer">
                <div style="text-align:center; color:#888; padding:20px;">Loading announcements...</div>
            </div>
        </div>

        <script>
            const API_BASE = '<%= ResolveUrl("~/webpage/api") %>';
            const USER_DEPT = '<%= UserDepartment %>';

            function formatWhen(dt) {
                if (!dt) return '';
                if (typeof dt === 'string') {
                    const m = dt.match(/\/Date\((\d+)(?:[+-]\d+)?\)\//);
                    if (m) {
                        const ms = parseInt(m[1], 10);
                        return new Date(ms).toLocaleString();
                    }
                    const d = new Date(dt);
                    if (!isNaN(d)) return d.toLocaleString();
                }
                try {
                    const d2 = new Date(dt);
                    if (!isNaN(d2)) return d2.toLocaleString();
                } catch (_) { }
                return '';
            }

            // Check if a date is within the last 24 hours (for "New" status)
            function isNew(dateValue) {
                if (!dateValue) return false;
                let postDate;
                if (typeof dateValue === 'string') {
                    const m = dateValue.match(/\/Date\((\d+)(?:[+-]\d+)?\)\//);
                    if (m) {
                        postDate = new Date(parseInt(m[1], 10));
                    } else {
                        postDate = new Date(dateValue);
                    }
                } else {
                    postDate = new Date(dateValue);
                }
                if (isNaN(postDate)) return false;
                const now = new Date();
                const hoursDiff = (now - postDate) / (1000 * 60 * 60);
                return hoursDiff <= 24; // Within the last 24 hours
            }

            // Store all announcements for filtering
            let allAnnouncements = [];
            let currentFilter = 'all';

            function composeInGmail(title, body) {
                const subject = encodeURIComponent("Company Announcement: " + title.substring(0, 50));
                const mailBody = encodeURIComponent(body + "\n\nSent from HRSIA Announcement System");
                const gmailUrl = `https://mail.google.com/mail/?view=cm&fs=1&su=${subject}&body=${mailBody}`;
                window.open(gmailUrl, '_blank');
            }

            document.addEventListener('DOMContentLoaded', loadAnnouncements);

            // Filter announcements by type
            function filterAnnouncements(filterType, evt) {
                currentFilter = filterType;

                // Update active tab
                document.querySelectorAll('.filter-tab').forEach(tab => tab.classList.remove('active'));
                if (evt && evt.currentTarget) {
                    evt.currentTarget.classList.add('active');
                }

                renderAnnouncements();
            }

            async function loadAnnouncements() {
                const container = document.getElementById('announcementsContainer');
                try {
                    const res = await fetch(`${API_BASE}/Announcements.ashx`, { cache: 'no-store' });
                    if (!res.ok) {
                        const t = await res.text();
                        container.innerHTML = '<p style="color:red;">Failed to load announcements.</p>';
                        console.error('Failed to load announcements:', t);
                        return;
                    }
                    allAnnouncements = await res.json();

                    if (!allAnnouncements || allAnnouncements.length === 0) {
                        container.innerHTML = '<div style="text-align:center; color:#888; padding:20px;">No announcements yet</div>';
                        return;
                    }

                    renderAnnouncements();
                } catch (e) {
                    console.error(e);
                    container.innerHTML = '<p style="color:red;">Failed to load announcements.</p>';
                }
            }

            function renderAnnouncements() {
                const container = document.getElementById('announcementsContainer');

                // Filter announcements based on current filter
                let filtered = allAnnouncements;
                if (currentFilter === 'new') {
                    filtered = allAnnouncements.filter(ann => {
                        const rawWhen = ann.postedDate || ann.PostedDate;
                        return isNew(rawWhen);
                    });
                } else if (currentFilter === 'pinned') {
                    filtered = allAnnouncements.filter(ann => ann.isPinned || ann.IsPinned);
                }

                // Always apply department restriction for Employee Viewpoint
                // Only show: 1. Target=Employee's Dept, 2. Target=General, 3. Target=HR Department (Global)
                filtered = filtered.filter(ann => {
                    const targetDept = (ann.department || ann.Department || '').toLowerCase();
                    const myDept = USER_DEPT.toLowerCase();

                    return myDept === 'all' || // Admins see all
                        targetDept === 'all' ||
                        targetDept === 'general' ||
                        targetDept === 'hr department' ||
                        targetDept === myDept;
                });

                // Sort: Pinned first, then by date
                filtered.sort((a, b) => {
                    const aPinned = a.isPinned || a.IsPinned;
                    const bPinned = b.isPinned || b.IsPinned;
                    if (aPinned && !bPinned) return -1;
                    if (!aPinned && bPinned) return 1;

                    const aDate = new Date(formatWhen(a.postedDate || a.PostedDate));
                    const bDate = new Date(formatWhen(b.postedDate || b.PostedDate));
                    return bDate - aDate;
                });

                if (filtered.length === 0) {
                    container.innerHTML = '<div style="text-align:center; color:#888; padding:20px;">No announcements found for this filter</div>';
                    return;
                }

                container.innerHTML = filtered.map(ann => {
                    // Determine if it's an admin post
                    const isHR = (ann.department === "Human Resources" || ann.Department === "Human Resources" || ann.department === "HR Department" || ann.Department === "HR Department");
                    const isAdmin = isHR; // Assuming HR = admin

                    const name = (ann.postedBy || ann.PostedBy || 'Anonymous');
                    const dept = (ann.department || ann.Department || 'Employee');
                    const body = (ann.content || ann.Content || '');
                    const rawWhen = (ann.postedDate || ann.PostedDate);
                    const when = formatWhen(rawWhen);
                    const isNewPost = isNew(rawWhen);

                    // Media handling
                    const imagePath = ann.imagePath || ann.ImagePath || '';
                    const videoPath = ann.videoPath || ann.VideoPath || '';

                    // Build badges
                    let badges = '';
                    if (isAdmin) {
                        badges += '<span class="admin-badge">Admin</span>';
                    }
                    if (isNewPost) {
                        badges += '<span class="new-badge">New</span>';
                    }
                    if (ann.isPinned || ann.IsPinned) {
                        badges += '<span class="pinned-badge"><svg style="width:10px;height:10px;fill:white;vertical-align:middle;margin-right:4px;" viewBox="0 0 24 24"><path d="M16,12V4H17V2H7V4H8V12L6,14V16H11.2V22H12.8V16H18V14L16,12Z"/></svg>Pinned</span>';
                    }

                    const nameDisplay = `<span>${name}</span>${badges}`;

                    let mediaHtml = '';
                    if (imagePath) {
                        mediaHtml = `<div style="margin-top: 12px;"><img src="${imagePath}" style="max-width: 100%; border-radius: 8px; border: 1px solid var(--border-color);" onerror="this.style.display='none'" /></div>`;
                    }
                    if (videoPath) {
                        // Fix video path - ensure it starts with the correct base path
                        const fixedVideoPath = videoPath.startsWith('/') ? videoPath : '/' + videoPath;
                        mediaHtml = `<div class="video-container"><video controls preload="metadata"><source src="${fixedVideoPath}" type="video/mp4" /><source src="${fixedVideoPath}" />Your browser does not support the video tag.</video></div>`;
                    }

                    // Determine card classes
                    let cardClasses = 'announcement-card';
                    if (ann.isPinned || ann.IsPinned) cardClasses += ' pinned-post';
                    if (isAdmin) cardClasses += ' admin';
                    if (isNewPost) cardClasses += ' new-post';

                    return `
                <div class="${cardClasses}">
                    <div class="card-header">
                        <div class="card-avatar">
                            <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI0MCIgaGVpZ2h0PSI0MCIgdmlld0JveD0iMCAwIDQwIDQwIj4KICA8Y2lyY2xlIGN4PSIyMCIgY3k9IjIwIiByPSIyMCIgZmlsbD0iIzk5OTkiLz4KICA8Y2lyY2xlIGN4PSIxNSIgY3k9IjE1IiByPSI3IiBmaWxsPSIjRkZGRkZGIi8+Cjwvc3ZnPg==" alt="${name}" />
                        </div>
                        <div class="card-info">
                            <div class="card-name">${nameDisplay}</div>
                            <div class="card-role">${dept}</div>
                            ${when ? `<div class="card-time">Posted ${when}</div>` : `<div class="card-time">Posted just now</div>`}
                        </div>
                    </div>
                    <div class="card-body">${body}</div>
                    ${mediaHtml}
                    <button class="btn-gmail" onclick="composeInGmail('${name}', '${body.replace(/'/g, "\\'").replace(/\n/g, " ")}')">
                        <svg style="width:16px;height:16px;" viewBox="0 0 24 24"><path fill="currentColor" d="M20,18H4V8L12,13L20,8V18M20,6H4C2.9,6 2,6.9 2,8V18C2,19.1 2.9,20 4,20H20C21.1,20 22,19.1 22,18V8C22,6.9 21.1,6 20,6Z"/></svg>
                        Compose in Gmail
                    </button>
                </div>`;
                }).join('');
            }
        </script>
    </asp:Content>