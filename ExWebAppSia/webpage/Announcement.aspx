<%@ Page Title="Announcement" Language="C#" MasterPageFile="~/webpage/HR.Master"
    AutoEventWireup="true" CodeBehind="Announcement.aspx.cs" Inherits="ExWebAppSia.webpage.WebForm4" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
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

        /* Create Announcement Panel */
        .create-panel {
            background-color: var(--panel-bg);
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 4px 12px rgba(164, 79, 86, 0.08);
            border: 2px solid var(--border-color);
        }

        .create-header {
            display: flex;
            align-items: flex-start;
            gap: 16px;
            margin-bottom: 20px;
        }

        .avatar-small {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            background: var(--accent-color);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary-color);
            font-size: 20px;
            border: 2px solid var(--primary-color);
        }

        .create-input {
            flex: 1;
            border: 1px solid #f0f0f0;
            border-radius: 12px;
            outline: none;
            background: #fdfaf9;
            font-size: 15px;
            color: var(--text-primary);
            padding: 12px 16px;
            font-family: inherit;
            transition: all 0.3s ease;
        }

        .create-input:focus {
            border-color: var(--primary-color);
            background: white;
            box-shadow: 0 0 0 4px rgba(164, 79, 86, 0.05);
        }

        /* Post Button */
        .post-button {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: white;
            border: none;
            border-radius: 12px;
            padding: 12px 32px;
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s ease;
            box-shadow: 0 4px 12px rgba(164, 79, 86, 0.2);
        }

        .post-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(164, 79, 86, 0.3);
        }

        .create-controls {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 10px;
            padding-top: 16px;
            border-top: 1px solid #f0f0f0;
        }

        .control-group {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .dept-select,
        .pin-toggle-btn {
            border: 1.5px solid var(--border-color);
            border-radius: 10px;
            padding: 8px 16px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            background: white;
            color: var(--text-secondary);
            transition: all 0.2s;
        }

        .pin-toggle-btn.pinned {
            background-color: var(--primary-color);
            color: white;
            border-color: var(--primary-color);
        }

        /* Action Icons */
        .action-icon-item {
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            padding: 8px 16px;
            border-radius: 10px;
            transition: background 0.2s;
            color: var(--text-secondary);
            font-weight: 600;
            font-size: 14px;
        }

        .action-icon-item:hover {
            background-color: var(--accent-color);
            color: var(--primary-color);
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

        /* Video/Image Preview */
        #mediaPreview {
            padding: 16px;
            background: #fdfaf9;
            border-radius: 12px;
            margin-bottom: 16px;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .create-controls { flex-direction: column; align-items: stretch; }
            .post-button { width: 100%; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container-box">
        <!-- Create Announcement Panel -->
        <div class="create-panel">
            <div class="create-header">
                <div class="avatar-small">
                    <i class="fas fa-user-shield"></i>
                </div>
                <textarea id="txtAnnouncement" class="create-input" placeholder="What's on your mind, Staff?"
                    maxlength="1000" rows="3"></textarea>
            </div>

            <!-- Media Preview -->
            <div id="mediaPreview" style="display: none;">
                <div id="imagePreview" style="display: none; position: relative;">
                    <img id="previewImg" style="max-width: 100%; max-height: 300px; border-radius: 12px;" />
                    <button type="button" onclick="removeImage()" style="position: absolute; top: 10px; right: 10px; background: rgba(0,0,0,0.5); color: white; border: none; border-radius: 50%; width: 30px; height: 30px;"><i class="fas fa-times"></i></button>
                </div>
                <div id="videoPreview" style="display: none; position: relative;">
                    <video id="previewVideo" controls style="max-width: 100%; max-height: 300px; border-radius: 12px;"></video>
                    <button type="button" onclick="removeVideo()" style="position: absolute; top: 10px; right: 10px; background: rgba(0,0,0,0.5); color: white; border: none; border-radius: 50%; width: 30px; height: 30px;"><i class="fas fa-times"></i></button>
                </div>
            </div>

            <div class="create-controls">
                <div class="control-group">
                    <div class="action-icon-item" onclick="document.getElementById('imageUpload').click();">
                        <i class="fas fa-image"></i>
                        <span>Photo</span>
                    </div>
                    <div class="action-icon-item" onclick="document.getElementById('videoUpload').click();">
                        <i class="fas fa-video"></i>
                        <span>Video</span>
                    </div>
                    
                    <select id="selDepartment" class="dept-select">
                        <option value="General">Target: All Departments</option>
                        <option value="Human Resources">Human Resources</option>
                        <option value="Research & Development">Research & Development</option>
                        <option value="Quality Control">Quality Control</option>
                        <option value="Finance">Finance</option>
                        <option value="Marketing">Marketing</option>
                        <option value="IT Support">IT Support</option>
                        <option value="Operations">Operations</option>
                        <option value="Sales">Sales</option>
                        <option value="Inventory">Inventory</option>
                        <option value="Customer Service">Customer Service</option>
                    </select>
                    <button type="button" id="btnPinToggle" class="pin-toggle-btn" onclick="togglePinState()">
                        <i class="fas fa-thumbtack"></i>
                        Pin Message
                    </button>
                </div>
                <button type="button" class="post-button" onclick="postAnnouncement()">Create Announcement</button>
            </div>

            <input type="file" id="imageUpload" accept="image/*" style="display: none;" onchange="handleImageSelect(event)" />
            <input type="file" id="videoUpload" accept="video/*" style="display: none;" onchange="handleVideoSelect(event)" />
        </div>

        <!-- Filter Tabs -->
        <div class="filter-tabs">
            <div class="filter-tab active" onclick="filterData('all', event)">
                <i class="fas fa-th-large"></i>
                <span>All Updates</span>
            </div>
            <div class="filter-tab" onclick="filterData('new', event)">
                <i class="fas fa-sparkles"></i>
                <span>Recent</span>
            </div>
            <div class="filter-tab" onclick="filterData('pinned', event)">
                <i class="fas fa-thumbtack"></i>
                <span>Pinned</span>
            </div>
        </div>

        <!-- Announcement Cards Container -->
        <div class="announcement-cards" id="announcementsContainer">
            <div style="text-align:center; color:var(--text-secondary); padding:40px;">
                <i class="fas fa-spinner fa-spin fa-2x"></i>
                <p style="margin-top:16px;">Synchronizing announcements...</p>
            </div>
        </div>
    </div>

    <script>
        const API_URL = '<%= ResolveUrl("~/webpage/api/Announcements.ashx") %>';
        let selectedImage = null;
        let selectedVideo = null;
        let isPinned = false;
        let allAnnouncements = [];
        let currentFilter = 'all';

        function togglePinState() {
            isPinned = !isPinned;
            const btn = document.getElementById('btnPinToggle');
            btn.classList.toggle('pinned', isPinned);
            btn.innerHTML = `<i class="fas fa-thumbtack"></i> ${isPinned ? 'Message Pinned' : 'Pin Message'}`;
        }

        function handleImageSelect(e) {
            const file = e.target.files[0];
            if (!file) return;
            selectedImage = file;
            selectedVideo = null;
            const reader = new FileReader();
            reader.onload = (ev) => {
                document.getElementById('previewImg').src = ev.target.result;
                document.getElementById('imagePreview').style.display = 'block';
                document.getElementById('videoPreview').style.display = 'none';
                document.getElementById('mediaPreview').style.display = 'block';
            };
            reader.readAsDataURL(file);
        }

        function handleVideoSelect(e) {
            const file = e.target.files[0];
            if (!file) return;
            selectedVideo = file;
            selectedImage = null;
            const reader = new FileReader();
            reader.onload = (ev) => {
                document.getElementById('previewVideo').src = ev.target.result;
                document.getElementById('videoPreview').style.display = 'block';
                document.getElementById('imagePreview').style.display = 'none';
                document.getElementById('mediaPreview').style.display = 'block';
            };
            reader.readAsDataURL(file);
        }

        function removeImage() {
            selectedImage = null;
            document.getElementById('imagePreview').style.display = 'none';
            checkMediaVisibility();
        }

        function removeVideo() {
            selectedVideo = null;
            document.getElementById('videoPreview').style.display = 'none';
            checkMediaVisibility();
        }

        function checkMediaVisibility() {
            if (!selectedImage && !selectedVideo) document.getElementById('mediaPreview').style.display = 'none';
        }

        async function postAnnouncement() {
            const content = document.getElementById('txtAnnouncement').value.trim();
            if (!content) { alert('Please write something first.'); return; }

            const formData = new FormData();
            formData.append('content', content);
            formData.append('isPinned', isPinned);
            formData.append('department', document.getElementById('selDepartment').value);
            if (selectedImage) formData.append('image', selectedImage);
            if (selectedVideo) formData.append('video', selectedVideo);

            const res = await fetch(API_URL, { method: 'POST', body: formData });
            if (res.ok) {
                document.getElementById('txtAnnouncement').value = '';
                removeImage(); removeVideo();
                if (isPinned) togglePinState();
                loadAnnouncements();
            } else {
                alert('Failed to post announcement.');
            }
        }

        async function loadAnnouncements() {
            const res = await fetch(API_URL);
            allAnnouncements = await res.json();
            renderAnnouncements();
        }

        function filterData(type, e) {
            currentFilter = type;
            document.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
            e.currentTarget.classList.add('active');
            renderAnnouncements();
        }

        function formatWhen(dt) {
            if (!dt) return 'Recently';
            if (typeof dt === 'string') {
                const m = dt.match(/\/Date\((\d+)(?:[+-]\d+)?\)\//);
                if (m) {
                    return new Date(parseInt(m[1], 10)).toLocaleString();
                }
                const d = new Date(dt);
                return !isNaN(d) ? d.toLocaleString() : 'Recently';
            }
            const d2 = new Date(dt);
            return !isNaN(d2) ? d2.toLocaleString() : 'Recently';
        }

        function renderAnnouncements() {
            const container = document.getElementById('announcementsContainer');
            let filtered = allAnnouncements;

            if (currentFilter === 'pinned') filtered = filtered.filter(a => a.IsPinned || a.isPinned);
            if (currentFilter === 'new') {
                const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000);
                filtered = filtered.filter(a => {
                    const d = new Date(a.PostedDate || a.postedDate);
                    return d > yesterday;
                });
            }

            if (filtered.length === 0) {
                container.innerHTML = '<div style="text-align:center; padding:40px; color:#888;">No announcements found here.</div>';
                return;
            }

            container.innerHTML = filtered.map(ann => `
                <div class="announcement-card ${ann.IsPinned ? 'pinned-mode' : ''}">
                    ${ann.IsPinned ? '<div class="pin-badge"><i class="fas fa-thumbtack"></i> Pinned</div>' : ''}
                    <div class="card-header">
                        <div class="poster-avatar">${(ann.PostedBy || 'A').charAt(0)}</div>
                        <div class="poster-info">
                            <h4>${ann.PostedBy || 'Admin'}</h4>
                            <span>${ann.Department || 'General'} • ${formatWhen(ann.PostedDate || ann.postedDate)}</span>
                        </div>
                    </div>
                    <div class="card-body">${ann.Content || ann.content}</div>
                    ${ann.ImageUrl ? `<img src="${ann.ImageUrl}" style="width:100%; border-radius:12px; margin-top:16px; border:1px solid #eee;" />` : ''}
                    ${ann.VideoUrl ? `<video controls style="width:100%; border-radius:12px; margin-top:16px;"><source src="${ann.VideoUrl}" /></video>` : ''}
                    <button class="btn-gmail" onclick="window.open('https://mail.google.com/mail/?view=cm&fs=1&su=Announcement: ${encodeURIComponent((ann.Content || '').substring(0,50))}&body=${encodeURIComponent(ann.Content || '')}', '_blank')">
                        <i class="fas fa-envelope"></i> Compose in Gmail
                    </button>
                </div>
            `).join('');
        }

        loadAnnouncements();
    </script>
</asp:Content>