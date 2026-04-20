<%@ Page Title="Hiring Pipeline" Language="C#" MasterPageFile="~/webpage(PresidentViewpoint)/President.Master"
    AutoEventWireup="true" Async="true" CodeBehind="RecruitmentStatus.aspx.cs" Inherits="ExWebAppSia.webpage_PresidentViewpoint_.RecruitmentStatus" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .recruitment-overview {
            padding: 24px;
            background: #fdfaf9;
        }

        .exec-card {
            background: white;
            border-radius: 20px;
            padding: 24px;
            box-shadow: 0 4px 20px rgba(164, 79, 86, 0.05);
            margin-bottom: 24px;
        }

        .status-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 32px;
        }

        .status-card {
            background: white;
            border-radius: 16px;
            padding: 24px;
            text-align: center;
            border: 1px solid #F0EEEE;
            transition: all 0.3s;
        }

        .status-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(164, 79, 86, 0.1);
            border-color: #A44F56;
        }

        .status-val {
            font-size: 32px;
            font-weight: 800;
            color: #4A3534;
            display: block;
        }

        .status-label {
            font-size: 12px;
            font-weight: 700;
            color: #9B7D7B;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-top: 4px;
        }

        .pipeline-table {
            width: 100%;
            border-collapse: collapse;
        }

        .pipeline-table th {
            padding: 16px;
            text-align: left;
            font-size: 13px;
            font-weight: 700;
            color: #9B7D7B;
            border-bottom: 2px solid #F0EEEE;
        }

        .pipeline-table td {
            padding: 16px;
            font-size: 14px;
            color: #4A3534;
            border-bottom: 1px solid #F5F5F5;
        }

        .status-badge {
            padding: 4px 12px;
            border-radius: 50px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
        }

        .badge-pending { background: #FFF3E0; color: #E65100; }
        .badge-interview { background: #E3F2FD; color: #1565C0; }
        .badge-hired { background: #E8F5E9; color: #2E7D32; }
        .badge-rejected { background: #FFEBEE; color: #C62828; }

        .job-card {
            background: #fff;
            border-radius: 12px;
            padding: 16px;
            border-left: 4px solid #A44F56;
            margin-bottom: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.02);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .job-title {
            font-weight: 700;
            color: #4A3534;
            font-size: 15px;
        }

        .job-meta {
            font-size: 12px;
            color: #9B7D7B;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="recruitment-overview">
        <div class="header-row mb-4">
            <h1 style="font-size: 24px; font-weight: 800; color: #4A3534;">Hiring Pipeline</h1>
            <p style="color: #6B4545;">Real-time monitoring of recruitment progress.</p>
        </div>

        <div class="status-grid">
            <div class="status-card">
                <span class="status-val"><asp:Literal ID="litTotalApplied" runat="server" /></span>
                <span class="status-label">Total Applicants</span>
            </div>
            <div class="status-card">
                <span class="status-val text-primary"><asp:Literal ID="litInterviewing" runat="server" /></span>
                <span class="status-label">Interviewing</span>
            </div>
            <div class="status-card">
                <span class="status-val text-success"><asp:Literal ID="litHired" runat="server" /></span>
                <span class="status-label">Recently Hired</span>
            </div>
            <div class="status-card">
                <span class="status-val text-danger"><asp:Literal ID="litRejected" runat="server" /></span>
                <span class="status-label">Rejected</span>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-8">
                <div class="exec-card">
                    <h2 style="font-size: 18px; font-weight: 700; color: #4A3534; margin-bottom: 20px;">Active Applicants</h2>
                    <div class="table-responsive">
                        <table class="pipeline-table">
                            <thead>
                                <tr>
                                    <th>Applicant Name</th>
                                    <th>Position Applied</th>
                                    <th>Applied Date</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptApplicants" runat="server">
                                    <ItemTemplate>
                                        <tr>
                                            <td style="font-weight: 600;"><%# Eval("FullName") %></td>
                                            <td><%# Eval("Role") %></td>
                                            <td><%# Eval("AppliedDate", "{0:MMM dd, yyyy}") %></td>
                                            <td>
                                                <span class="status-badge <%# GetStatusClass(Eval("Status")) %>">
                                                    <%# Eval("Status") %>
                                                </span>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            
            <div class="col-lg-4">
                <div class="exec-card">
                    <h2 style="font-size: 18px; font-weight: 700; color: #4A3534; margin-bottom: 20px;">Open Positions</h2>
                    <asp:Repeater ID="rptJobs" runat="server">
                        <ItemTemplate>
                            <div class="job-card">
                                <div>
                                    <div class="job-title"><%# Eval("Title") %></div>
                                    <div class="job-meta"><%# Eval("Department") %> • <%# Eval("Type") %></div>
                                </div>
                                <div style="text-align: right;">
                                    <div style="font-weight: 800; color: #A44F56;"><%# Eval("ApplicantCount") %></div>
                                    <div style="font-size: 10px; color: #9B7D7B;">APPLICANTS</div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

