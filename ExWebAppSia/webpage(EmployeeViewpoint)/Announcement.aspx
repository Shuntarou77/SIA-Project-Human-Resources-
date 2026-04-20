<%@ Page Title="Announcements" Language="C#" MasterPageFile="~/webpage(EmployeeViewpoint)/EmployeeHR.Master"
    AutoEventWireup="true" CodeBehind="Announcement.aspx.cs" Inherits="ExWebAppSia.webpage_EmployeeViewpoint_.WebForm4"
    %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <style>
            @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');

            :root {
                --primary-color: #A44F56;
                --secondary-color: #DE9D9D;
                --accent-color: #FFE8E8;
                --text-primary: #4A2E2E;
                --text-secondary: #6B4545;
                --border-color: #E8C4C4;
                --panel-bg: #ffffff;
            }

            .container-box {
                width: 100%;
                min-height: 100vh;
                padding: 24px;
                background-color: #fdfaf9;
                display: flex;
                flex-direction: column;
                gap: 20px;
                font-family: 'Poppins', sans-serif;
            }

            /* Filter Tabs */
            .filter-tabs {
                display: flex;
                gap: 12px;
                margin-top: 12px;
            }

            .filter-tab {
                padding: 10px 24px;
                border-radius: 12px;
                background: white;
                border: 2px solid var(--border-color);
                color: var(--text-secondary);
                font-weight: 700;
                font-size: 14px;
                cursor: pointer;
                transition: all 0.2s;
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .filter-tab:hover {
                border-color: var(--primary-color);
                color: var(--primary-color);
            }

            .filter-tab.active {
                background: var(--primary-color);
                color: white;
                border-color: var(--primary-color);
                box-shadow: 0 4px 12px rgba(164, 79, 86, 0.2);
            }

            /* Announcement Cards */
            .announcement-cards {
                display: flex;
                flex-direction: column;
                gap: 20px;
                margin-top: 10px;
            }

            .announcement-card {
                background: white;
                border-radius: 16px;
                padding: 24px;
                border: 2px solid var(--border-color);
                box-shadow: 0 4px 12px rgba(164, 79, 86, 0.05);
                position: relative;
                transition: all 0.3s ease;
            }

            .announcement-card:hover {
                box-shadow: 0 8px 24px rgba(164, 79, 86, 0.12);
                transform: translateY(-2px);
            }

            .card-header {
                display: flex;
                align-items: center;
                gap: 16px;
                margin-bottom: 16px;
            }

            .poster-avatar {
                width: 44px;
                height: 44px;
                border-radius: 12px;
                background: var(--accent-color);
                display: flex;
                align-items: center;
                justify-content: center;
                color: var(--primary-color);
                font-weight: 800;
                font-family: 'Poppins', sans-serif;
            }

            .poster-info h4 {
                font-size: 15px;
                font-weight: 800;
                color: var(--text-primary);
                margin: 0;
            }

            .poster-info span {
                font-size: 12px;
                color: var(--text-secondary);
                font-weight: 600;
            }

            .card-body {
                font-size: 15px;
                color: var(--text-primary);
                line-height: 1.6;
                white-space: pre-wrap;
            }

            .pin-badge {
                position: absolute;
                top: 24px;
                right: 24px;
                padding: 4px 12px;
                background: #3b82f6;
                color: white;
                font-size: 11px;
                font-weight: 800;
                border-radius: 50px;
                display: flex;
                align-items: center;
                gap: 6px;
                text-transform: uppercase;
            }

            .new-badge-ui {
                padding: 4px 12px;
                background: #22c55e;
                color: white;
                font-size: 11px;
                font-weight: 800;
                border-radius: 50px;
                display: inline-flex;
                align-items: center;
                margin-left: 8px;
                text-transform: uppercase;
            }

            .btn-gmail {
                margin-top: 20px;
                padding: 8px 16px;
                border-radius: 8px;
                background: #FDF1F0;
                color: #D93025;
                font-weight: 700;
                font-size: 13px;
                border: 1px solid #F5C2C0;
                cursor: pointer;
                display: flex;
                align-items: center;
                gap: 8px;
                transition: all 0.2s;
            }

            .btn-gmail:hover {
                background: #FADAD6;
            }

            /* Responsive */
            @media (max-width: 768px) {
                .container-box { padding: 16px; }
            }
        </style>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        <div class="container-box">
            <!-- Filter Tabs -->
            <div class="filter-tabs">
                <div class="filter-tab active" onclick="filterAnnouncements('all', event)">
                    <i class="fas fa-th-large"></i>
                    <span>All Updates</span>
                </div>
                <div class="filter-tab" onclick="filterAnnouncements('new', event)">
                    <i class="fas fa-sparkles"></i>
                    <span>Recent</span>
                </div>
                <div class="filter-tab" onclick="filterAnnouncements('pinned', event)">
                    <i class="fas fa-thumbtack"></i>
                    <span>Pinned</span>
                </div>
            </div>

            <!-- Announcement Cards Container -->
            <div class="announcement-cards" id="announcementsContainer">
                <div style="text-align:center; color:var(--text-secondary); padding:40px;">
                    <i class="fas fa-spinner fa-spin fa-2x"></i>
                    <p style="margin-top:16px;">Loading announcements...</p>
                </div>
            </div>
        </div>

        <script>
            const API_BASE = '<%= ResolveUrl("~/webpage/api") %>';
            const USER_DEPT = '<%= UserDepartment %>';
            let allAnnouncements = [];
            let currentFilter = 'all';

            function formatWhen(dt) {
                if (!dt) return '';
                if (typeof dt === 'string') {
                    const m = dt.match(/\/Date\((\d+)(?:[+-]\d+)?\)\//);
                    if (m) return new Date(parseInt(m[1], 10)).toLocaleString();
                    const d = new Date(dt);
                    if (!isNaN(d)) return d.toLocaleString();
                }
                const d2 = new Date(dt);
                return !isNaN(d2) ? d2.toLocaleString() : '';
            }

            function isNew(dateValue) {
                if (!dateValue) return false;
                let postDate;
                if (typeof dateValue === 'string') {
                    const m = dateValue.match(/\/Date\((\d+)(?:[+-]\d+)?\)\//);
                    postDate = m ? new Date(parseInt(m[1], 10)) : new Date(dateValue);
                } else postDate = new Date(dateValue);
                if (isNaN(postDate)) return false;
                return (new Date() - postDate) / (1000 * 60 * 60) <= 24;
            }

            document.addEventListener('DOMContentLoaded', loadAnnouncements);

            function filterAnnouncements(filterType, evt) {
                currentFilter = filterType;
                document.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
                if (evt && evt.currentTarget) evt.currentTarget.classList.add('active');
                renderAnnouncements();
            }

            async function loadAnnouncements() {
                const container = document.getElementById('announcementsContainer');
                try {
                    const res = await fetch(`${API_BASE}/Announcements.ashx`, { cache: 'no-store' });
                    allAnnouncements = await res.json();
                    renderAnnouncements();
                } catch (e) {
                    console.error(e);
                    container.innerHTML = '<p style="color:red; text-align:center;">Failed to load announcements.</p>';
                }
            }

            function renderAnnouncements() {
                const container = document.getElementById('announcementsContainer');
                let filtered = allAnnouncements;

                // 1. Initial filter based on tabs
                if (currentFilter === 'new') filtered = filtered.filter(a => isNew(a.postedDate || a.PostedDate));
                else if (currentFilter === 'pinned') filtered = filtered.filter(a => a.isPinned || a.IsPinned);

                // 2. Departmental security check
                filtered = filtered.filter(ann => {
                    const target = (ann.department || ann.Department || '').toLowerCase();
                    const mine = USER_DEPT.toLowerCase();
                    return mine === 'all' || target === 'all' || target === 'general' || target === 'hr department' || target === mine;
                });

                // 3. Sorting
                filtered.sort((a, b) => {
                    const ap = a.isPinned || a.IsPinned;
                    const bp = b.isPinned || b.IsPinned;
                    if (ap && !bp) return -1;
                    if (!ap && bp) return 1;
                    return new Date(formatWhen(b.postedDate || b.PostedDate)) - new Date(formatWhen(a.postedDate || a.PostedDate));
                });

                if (filtered.length === 0) {
                    container.innerHTML = '<div style="text-align:center; padding:40px; color:#888;">No announcements found.</div>';
                    return;
                }

                container.innerHTML = filtered.map(ann => {
                    const pBy = ann.postedBy || ann.PostedBy || 'Admin';
                    const content = ann.content || ann.Content || '';
                    const rawWhen = ann.postedDate || ann.PostedDate;
                    const isPinned = ann.isPinned || ann.IsPinned;
                    const isNewPost = isNew(rawWhen);
                    const img = ann.imagePath || ann.ImagePath || '';
                    const vid = ann.videoPath || ann.VideoPath || '';

                    return `
                        <div class="announcement-card">
                            ${isPinned ? '<div class="pin-badge"><i class="fas fa-thumbtack"></i> Pinned</div>' : ''}
                            <div class="card-header">
                                <div class="poster-avatar">${pBy.charAt(0)}</div>
                                <div class="poster-info">
                                    <h4>${pBy}${isNewPost ? '<span class="new-badge-ui">New</span>' : ''}</h4>
                                    <span>${ann.department || ann.Department || 'General'} • ${formatWhen(rawWhen)}</span>
                                </div>
                            </div>
                            <div class="card-body">${content}</div>
                            ${img ? `<img src="${img}" style="width:100%; border-radius:12px; margin-top:16px; border:1px solid #eee;" />` : ''}
                            ${vid ? `<div style="margin-top:16px;"><video controls style="width:100%; border-radius:12px;"><source src="${vid}" /></video></div>` : ''}
                            <button class="btn-gmail" onclick="window.open('https://mail.google.com/mail/?view=cm&fs=1&su=Announcement: ${encodeURIComponent(content.substring(0,50))}&body=${encodeURIComponent(content)}', '_blank')">
                                <i class="fas fa-envelope"></i> Compose in Gmail
                            </button>
                        </div>`;
                }).join('');
            }
        </script>
    </asp:Content>