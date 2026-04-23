<%@ Page Title="Organizational Chart" Language="C#" MasterPageFile="~/webpage(SuperAdminViewpoint)/SuperAdmin.Master" AutoEventWireup="true" CodeFile="OrgChart.aspx.cs" Inherits="ExWebAppSia.webpage_SuperAdminViewpoint_.SuperAdminOrgChart" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!-- Library CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/orgchart/3.1.1/css/jquery.orgchart.min.css" />
    
    <style>
        :root {
            --bg-color: #f8fafc;
            --panel-bg: #ffffff;
            --text-dark: #202d41;
            /* Unified Brand Color */
            --accent: #A36A66;
            --accent-light: #C49A99;
            --accent-dark: #8B5A58;
            --border-color: #e8e8e8;
            --shadow-sm: 0 2px 4px rgba(0, 0, 0, 0.05);
            --shadow-md: 0 4px 12px rgba(0, 0, 0, 0.08);
            --shadow-lg: 0 12px 24px rgba(0, 0, 0, 0.12);
        }

        .org-container {
            padding: 10px 20px 40px;
            background-color: transparent;
        }

        /* Unified Header Style */
        .page-header {
            display: flex;
            align-items: center;
            gap: 20px;
            margin-bottom: 35px;
            padding: 24px 30px;
            background: linear-gradient(to right, #ffffff, #fdfbfb);
            border-radius: 16px;
            border: 1px solid var(--border-color);
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.02);
        }

        .header-icon {
            width: 56px;
            height: 56px;
            background: var(--accent);
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 24px;
            box-shadow: 0 4px 10px rgba(163, 106, 102, 0.3);
        }

        .header-content {
            flex: 1;
        }

        .page-title {
            font-size: 28px;
            font-weight: 800;
            color: var(--text-dark);
            margin: 0;
            letter-spacing: -0.5px;
            line-height: 1.2;
        }

        .page-subtitle {
            color: #64748b;
            margin: 4px 0 0;
            font-size: 14px;
            font-weight: 500;
        }

        .controls {
            display: flex;
            gap: 12px;
        }

        .btn-control {
            border: 1px solid var(--border-color);
            background: white;
            padding: 10px 18px;
            border-radius: 10px;
            color: #475569;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            align-items: center;
            gap: 8px;
            box-shadow: var(--shadow-sm);
        }

        .btn-control:hover {
            border-color: var(--accent);
            color: var(--accent);
            background: #fffafa;
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }

        .btn-control i {
            font-size: 14px;
        }

        /* Main Card Container */
        .org-card {
            background: white;
            border-radius: 20px;
            border: 1px solid var(--border-color);
            box-shadow: var(--shadow-md);
            overflow: hidden;
            position: relative;
            background-image: 
                radial-gradient(#e5e7eb 0.5px, transparent 0.5px),
                radial-gradient(#e5e7eb 0.5px, #ffffff 0.5px);
            background-size: 20px 20px;
            background-position: 0 0, 10px 10px;
            height: calc(100vh - 250px);
        }

        /* OrgChart Library Overrides */
        #chart-container {
            height: 100%;
            width: 100%;
            overflow: auto;
            text-align: center;
        }

        .orgchart {
            background: transparent !important;
        }

        .orgchart .node {
            width: 260px;
            padding: 0;
            margin: 10px 20px;
            border: none;
            background-color: transparent !important;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .orgchart .node:hover {
            background-color: transparent !important;
            transform: translateY(-10px) scale(1.02);
            z-index: 10;
        }

        .orgchart .node .title {
            width: 100%;
            box-sizing: border-box;
            height: auto;
            min-height: 60px;
            line-height: 1.4;
            font-size: 15px;
            font-weight: 800;
            color: #fff !important;
            background: var(--accent) !important;
            border-radius: 16px 16px 0 0 !important;
            text-shadow: 0 1px 2px rgba(0,0,0,0.2);
            padding: 15px 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            white-space: normal;
            word-wrap: break-word;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        /* Remove any injected icons from the title */
        .orgchart .node .title::before,
        .orgchart .node .title::after,
        .orgchart .node .title i {
            display: none !important;
        }

        .orgchart .node .content {
            width: 100%;
            box-sizing: border-box;
            height: auto;
            min-height: 80px;
            line-height: 1.6;
            font-size: 14px;
            font-weight: 600;
            color: #334155 !important;
            background: #fff !important;
            border: 1px solid var(--border-color) !important;
            border-top: none !important;
            border-radius: 0 0 16px 16px !important;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05) !important;
            padding: 15px 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            white-space: normal;
            word-wrap: break-word;
        }

        /* Line Styling */
        .orgchart .lines .downLine {
            background-color: var(--accent-light) !important;
            width: 2px;
        }
        .orgchart .lines .leftLine {
            border-left: 2px solid var(--accent-light) !important;
            border-top: 2px solid var(--accent-light) !important;
        }
        .orgchart .lines .rightLine {
            border-right: 2px solid var(--accent-light) !important;
            border-top: 2px solid var(--accent-light) !important;
        }
        .orgchart .lines .topLine {
            border-top: 2px solid var(--accent-light) !important;
        }

        /* Specialized Node Colors */
        .orgchart .node.president-node .title {
            background: linear-gradient(135deg, #2d3436 0%, #000000 100%) !important;
        }
        
        .orgchart .node.superadmin-node .title {
            background: linear-gradient(135deg, #636e72 0%, #2d3436 100%) !important;
        }

        .orgchart .node.manager-node .title {
            background: linear-gradient(135deg, #636e72 0%, #2d3436 100%) !important;
        }

        .orgchart .node.employee-node .title {
            background: #fff !important;
            color: #1e293b !important;
            border: 1px solid var(--border-color) !important;
            border-bottom: none !important;
        }

        /* Loading Animation */
        .loading-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: white;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            z-index: 100;
        }

        .spinner {
            width: 50px;
            height: 50px;
            border: 4px solid #f1f5f9;
            border-top: 4px solid var(--accent);
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-bottom: 20px;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* Scrollbar Styling */
        .org-card::-webkit-scrollbar {
            width: 8px;
            height: 8px;
        }
        .org-card::-webkit-scrollbar-track {
            background: #f1f5f9;
        }
        .org-card::-webkit-scrollbar-thumb {
            background: var(--accent-light);
            border-radius: 10px;
        }
        .org-card::-webkit-scrollbar-thumb:hover {
            background: var(--accent);
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="org-container">
        <div class="page-header">
            <div class="header-icon">
                <i class="fas fa-sitemap"></i>
            </div>
            <div class="header-content">
                <h1 class="page-title">Organizational Structure</h1>
                <p class="page-subtitle">Dynamic visualization of department hierarchy and personnel reporting lines.</p>
            </div>
            <div class="controls">
                <button type="button" class="btn-control" onclick="exportJSON()">
                    <i class="fas fa-download"></i> Export data
                </button>
                <button type="button" class="btn-control" onclick="resetView()">
                    <i class="fas fa-sync-alt"></i> Reset view
                </button>
            </div>
        </div>

        <div class="org-card">
            <div id="loading" class="loading-overlay">
                <div class="spinner"></div>
                <p style="font-weight: 700; color: #64748b; letter-spacing: 0.5px;">CONSTRUCTING GRAPH...</p>
            </div>
            <div id="chart-container"></div>
        </div>
    </div>

    <!-- Library JS -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.4/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/orgchart/3.1.1/js/jquery.orgchart.min.js"></script>

    <script type="text/javascript">
        var chart;
        var orgData;

        $(function() {
            loadOrgData();
        });

        function loadOrgData() {
            const handlerUrl = '<%= ResolveUrl("~/Handler/OrgChartHandler.ashx") %>';
            $.getJSON(handlerUrl, function(data) {
                if (data.error) {
                    $('#loading').html('<div style="color: #ef4444; font-weight: 600;">Error: ' + data.error + '</div>');
                    return;
                }
                orgData = data;
                initChart(data);
                setTimeout(() => {
                    $('#loading').fadeOut(500);
                }, 800);
            }).fail(function() {
                $('#loading').html('<div style="color: #ef4444; font-weight: 600;">System connection failed. Please refresh.</div>');
            });
        }

        function initChart(datasource) {
            chart = $('#chart-container').orgchart({
                'data': datasource,
                'nodeContent': 'title',
                'nodeTitle': 'name',
                'pan': true,
                'zoom': true,
                'verticalLevel': 4,
                'createNode': function($node, data) {
                    $node.addClass(data.className);
                }
            });
        }

        function resetView() {
            if(chart) {
                $('#chart-container').empty();
                initChart(orgData);
            }
        }

        function exportJSON() {
            if (!orgData) return;
            const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(orgData, null, 2));
            const downloadAnchorNode = document.createElement('a');
            downloadAnchorNode.setAttribute("href", dataStr);
            downloadAnchorNode.setAttribute("download", "company_structure.json");
            document.body.appendChild(downloadAnchorNode);
            downloadAnchorNode.click();
            downloadAnchorNode.remove();
        }
    </script>
</asp:Content>
