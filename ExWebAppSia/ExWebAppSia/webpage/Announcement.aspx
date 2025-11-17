<%@ Page Title="" Language="C#" MasterPageFile="~/webpage/HR.Master" AutoEventWireup="true" CodeBehind="Announcement.aspx.cs" Inherits="ExWebAppSia.webpage.WebForm4" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        :root {
            --bg-color: #ffffff;                /* ✅ Pure white background */
            --panel-bg: #ffffff;
            --text-dark: #333333;
            --border-color: #e8e8e8;
            --hover-bg: #f9f9f9;
            --accent: #A36A66;                 /* ✅ Unified brand color */
            --accent-light: #C49A99;           /* Lighter tint */
            --accent-dark: #8B5A58;            /* Darker on hover/active */
            --admin-bg: #F8ECEB;               /* Soft warm tint (replaces #FFF5F5) */
            --admin-border: #D8BFBF;           /* Harmonious border */
        }

        html, body {
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

        /* Create Announcement Panel */
        .create-panel {
            background-color: var(--panel-bg);
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            border: 1px solid var(--border-color);
        }

        .create-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 15px;
        }

        .avatar-small {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            overflow: hidden;
            border: 1px solid var(--border-color);
        }

        .avatar-small img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .create-input {
            flex: 1;
            border: none;
            outline: none;
            background: transparent;
            font-size: 16px;
            color: var(--text-dark);
            padding: 8px 0;
        }

        .create-input::placeholder {
            color: #aaa;
        }

        /* Post Button — ✅ Updated to #A36A66 */
        .post-button {
            background: linear-gradient(135deg, var(--accent), var(--accent-dark));
            color: white;
            border: none;
            border-radius: 24px;
            padding: 8px 24px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 10px;
            align-self: flex-end;
            transition: all 0.2s ease;
            box-shadow: 0 2px 4px rgba(163, 106, 102, 0.2);
        }

        .post-button:hover {
            background: linear-gradient(135deg, var(--accent-dark), #7A4F4D);
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(163, 106, 102, 0.3);
        }

        /* Action Icons */
        .action-icons {
            display: flex;
            justify-content: space-between;
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid var(--border-color);
        }

        .action-icon-item {
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            padding: 8px 12px;
            border-radius: 8px;
            transition: background 0.2s;
        }

        .action-icon-item:hover {
            background-color: var(--hover-bg);
        }

        .action-icon {
            width: 20px;
            height: 20px;
            fill: #666; /* neutral */
        }

        .action-label {
            font-size: 14px;
            color: var(--text-dark);
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
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            border: 1px solid var(--border-color);
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .announcement-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
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

        /* Responsive */
        @media (max-width: 768px) {
            .container-box {
                padding: 12px;
            }

            .create-header {
                flex-direction: column;
                align-items: stretch;
                gap: 10px;
            }

            .post-button {
                align-self: center;
                width: 100%;
                max-width: 200px;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container-box">
        <!-- Create Announcement Panel -->
        <div class="create-panel">
            <div class="create-header">
                <div class="avatar-small">
                    <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI0MCIgaGVpZ2h0PSI0MCIgdmlld0JveD0iMCAwIDQwIDQwIj4KICA8Y2lyY2xlIGN4PSIyMCIgY3k9IjIwIiByPSIyMCIgZmlsbD0iIzk5OTkiLz4KICA8Y2lyY2xlIGN4PSIxNSIgY3k9IjE1IiByPSI3IiBmaWxsPSIjRkZGRkZGIi8+Cjwvc3ZnPg==" alt="You" />
                </div>
                <input type="text" id="txtAnnouncement" class="create-input" placeholder="Create announcement..." maxlength="300" />
            </div>
            <button type="button" class="post-button" onclick="postAnnouncement(); return false;">Post</button>

            <div class="action-icons">
                <div class="action-icon-item">
                    <svg class="action-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                        <path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-4 6h-4v6h4v-6z"/>
                    </svg>
                    <span class="action-label">Photo</span>
                </div>
                <div class="action-icon-item">
                    <svg class="action-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                        <path d="M17 10.5V7c0-.55-.45-1-1-1H4c-.55 0-1 .45-1 1v10c0 .55.45 1 1 1h12c.55 0 1-.45 1-1v-3.5l4 4v-11l-4 4z"/>
                    </svg>
                    <span class="action-label">Video</span>
                </div>
                <div class="action-icon-item">
                    <svg class="action-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                        <path d="M17 12h-5v6h5v-6zm2-5H7v2h12V7zM14 15h2v6h-2v-6z"/>
                    </svg>
                    <span class="action-label">Events</span>
                </div>
            </div>
        </div>

        <!-- Filter Tabs -->
        <div class="filter-tabs">
            <div class="filter-tab active">
                <svg class="filter-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                    <path d="M3 13h8V3H3v10zm0 8h8v-6H3v6zm10-18h8v10h-8V3zm0 14h8v-6h-8v6z"/>
                </svg>
                <span>All</span>
            </div>
            <div class="filter-tab">
                <svg class="filter-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                    <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-2-2 1.41-1.41L10 14.17l6.59-6.59L18 9l-8 8z"/>
                </svg>
                <span>New</span>
            </div>
            <div class="filter-tab">
                <svg class="filter-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                    <path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 11h2v2h-2v-2zm0-8h2v6h-2V6z"/>
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

        document.addEventListener('DOMContentLoaded', loadAnnouncements);

        async function postAnnouncement() {
            const content = document.getElementById('txtAnnouncement').value.trim();
            if (!content) { alert('Please enter an announcement.'); return; }

            const response = await fetch(`${API_BASE}/Announcements.ashx`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ content })
            });

            if (!response.ok) {
                const t = await response.text();
                alert('Failed to post announcement:\n' + t);
                return;
            }

            document.getElementById('txtAnnouncement').value = '';
            await loadAnnouncements();
        }

        async function loadAnnouncements() {
            const container = document.getElementById('announcementsContainer');
            try {
                const res = await fetch(`${API_BASE}/Announcements.ashx`, { cache: 'no-store' });
                if (!res.ok) {
                    const t = await res.text();
                    container.innerHTML = '<p style="color:red;">Failed to load announcements.</p>';
                    alert('Failed to load announcements:\n' + t);
                    return;
                }
                const announcements = await res.json();

                if (!announcements || announcements.length === 0) {
                    container.innerHTML = '<div style="text-align:center; color:#888; padding:20px;">No announcements yet</div>';
                    return;
                }

                container.innerHTML = announcements.map(ann => {
                    // Determine if it's an admin post
                    const isHR = (ann.department === "Human Resources" || ann.Department === "Human Resources");
                    const isAdmin = isHR; // Assuming HR = admin

                    const name = (ann.postedBy || ann.PostedBy || 'Anonymous');
                    const dept = (ann.department || ann.Department || 'Employee');
                    const body = (ann.content || ann.Content || '');
                    const rawWhen = (ann.postedDate || ann.PostedDate);
                    const when = formatWhen(rawWhen);

                    // Add "Admin" badge if HR
                    const nameDisplay = isAdmin
                        ? `<span>${name}</span><span class="admin-badge">Admin</span>`
                        : `<span>${name}</span>`;

                    return `
                        <div class="announcement-card ${isAdmin ? 'admin' : ''}">
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
                        </div>`;
                }).join('');
            } catch (e) {
                console.error(e);
                container.innerHTML = '<p style="color:red;">Failed to load announcements.</p>';
            }
        }
    </script>
</asp:Content>