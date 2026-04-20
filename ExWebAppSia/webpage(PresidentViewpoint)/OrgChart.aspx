<%@ Page Title="Organizational Chart" Language="C#" MasterPageFile="~/webpage(PresidentViewpoint)/President.Master" AutoEventWireup="true" CodeBehind="OrgChart.aspx.cs" Inherits="ExWebAppSia.webpage_PresidentViewpoint_.PresidentOrgChart" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!-- Library CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/orgchart/3.1.1/css/jquery.orgchart.min.css" />
    
    <style>
        .page-header {
            margin-bottom: 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .page-title {
            font-size: 1.75rem;
            font-weight: 800;
            color: #1A202C;
            margin: 0;
        }

        .chart-container {
            position: relative;
            display: inline-block;
            top: 10px;
            left: 10px;
            height: calc(100vh - 200px);
            width: calc(100% - 20px);
            border: none;
            overflow: auto;
            text-align: center;
            background: #f8f9fa;
            border-radius: 24px;
            box-shadow: inset 0 2px 10px rgba(0,0,0,0.05);
            padding: 40px;
        }

        #chart-container {
            background-color: transparent;
        }

        /* Custom Node Styling */
        .orgchart .node {
            box-sizing: border-box;
            display: inline-block;
            position: relative;
            margin: 0;
            padding: 3px;
            border: none;
            text-align: center;
            width: 140px;
        }

        .orgchart .node .title {
            text-align: center;
            font-size: 12px;
            font-weight: bold;
            height: 24px;
            line-height: 24px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            background-color: #333;
            color: #fff;
            border-radius: 4px 4px 0 0;
        }

        .orgchart .node .content {
            box-sizing: border-box;
            width: 100%;
            height: 40px;
            font-size: 11px;
            line-height: 18px;
            border: 1px solid #ccc;
            border-radius: 0 0 4px 4px;
            text-align: center;
            background-color: #fff;
            color: #333;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: wrap;
            padding: 4px;
        }

        /* Premium Node Styles */
        .orgchart .node {
            transition: transform 0.3s;
        }

        .orgchart .node:hover {
            transform: translateY(-5px);
            z-index: 10;
        }

        /* President Node */
        .orgchart .node.president-node .title {
            background: linear-gradient(135deg, #4A3534 0%, #2D1B1B 100%) !important;
            font-size: 11px !important;
            height: 24px;
            line-height: 24px;
        }
        .orgchart .node.president-node .content {
            border: 2px solid #4A3534;
            font-weight: bold;
            font-size: 10px;
        }

        /* SuperAdmin Node */
        .orgchart .node.superadmin-node .title {
            background: linear-gradient(135deg, #A44F56 0%, #7D3A40 100%) !important;
        }
        .orgchart .node.superadmin-node .content {
            border: 1px solid #A44F56;
        }

        /* Manager Node */
        .orgchart .node.manager-node .title {
            background: linear-gradient(135deg, #5D7987 0%, #4A606B 100%) !important;
        }
        .orgchart .node.manager-node .content {
            border: 1px solid #5D7987;
        }

        /* Regular Employee Node */
        .orgchart .node.employee-node .title {
            background-color: #f1f3f5 !important;
            color: #495057 !important;
            border: 1px solid #dee2e6;
            border-bottom: none;
        }
        .orgchart .node.employee-node .content {
            border: 1px solid #dee2e6;
        }

        /* Lines styling */
        .orgchart .lines .downLine {
            background-color: #A44F56;
        }
        .orgchart .lines .leftLine, .orgchart .lines .rightLine {
            border-color: #A44F56;
        }
        .orgchart .lines .topLine {
            border-color: #A44F56;
        }

        .controls {
            background: white;
            padding: 10px 20px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            display: flex;
            gap: 10px;
        }

        .btn-control {
            border: 1px solid #dee2e6;
            background: white;
            padding: 8px 12px;
            border-radius: 8px;
            color: #4A5568;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .btn-control:hover {
            border-color: #A44F56;
            color: #A44F56;
            background: #FFF5F5;
        }

        /* Animation */
        @keyframes fadeIn {
            from { opacity: 0; transform: scale(0.95); }
            to { opacity: 1; transform: scale(1); }
        }

        .chart-container {
            animation: fadeIn 0.6s ease-out forwards;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page-header">
        <div>
            <h1 class="page-title">Corporate Hierarchy</h1>
            <p class="text-muted m-0">Interactive organizational chart of SHE Essentials personnel.</p>
        </div>
        <div class="controls">
            <button type="button" class="btn-control" onclick="exportJSON()">
                <i class="fas fa-file-export"></i> Export JSON
            </button>
            <button type="button" class="btn-control" onclick="chart.init({'pan':true, 'zoom':true})">
                <i class="fas fa-expand"></i> Reset View
            </button>
        </div>
    </div>

    <div class="chart-container">
        <div id="loading" style="padding: 100px;">
            <i class="fas fa-spinner fa-spin fa-3x" style="color: #A44F56;"></i>
            <p style="margin-top: 15px; font-weight: 600; color: #4A5568;">Building company structure...</p>
        </div>
        <div id="chart-container"></div>
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
                    console.error("Error fetching data:", data.error);
                    $('#loading').html('<div class="alert alert-danger">Error: ' + data.error + '</div>');
                    return;
                }

                orgData = data;
                initChart(data);
                $('#loading').hide();
            }).fail(function(jqxhr, textStatus, error) {
                const err = textStatus + ", " + error;
                console.error("Request Failed: " + err);
                $('#loading').html('<div class="alert alert-danger">Failed to load data from server. Please refresh or contact support.</div>');
            });
        }

        function initChart(datasource) {
            chart = $('#chart-container').orgchart({
                'data': datasource,
                'nodeContent': 'title',
                'nodeTitle': 'name',
                'pan': true,
                'zoom': true,
                'verticalLevel': 4, // Managers stay horizontal, Staff under them become vertical to save space
                'createNode': function($node, data) {
                    $node.addClass(data.className);
                }
            });
        }

        function exportJSON() {
            if (!orgData) return;
            const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(orgData, null, 2));
            const downloadAnchorNode = document.createElement('a');
            downloadAnchorNode.setAttribute("href", dataStr);
            downloadAnchorNode.setAttribute("download", "company_orgchart.json");
            document.body.appendChild(downloadAnchorNode);
            downloadAnchorNode.click();
            downloadAnchorNode.remove();
        }
    </script>
</asp:Content>

