<%@ Page Title="Announcements" Language="C#" MasterPageFile="~/webpage(EmployeeViewpoint)/EmployeeHR.Master" AutoEventWireup="true" CodeBehind="Announcement.aspx.cs" Inherits="ExWebAppSia.webpage_EmployeeViewpoint_.WebForm4" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        :root {
            --primary-pink: #ff6b8b;
            --light-pink: #ffe6ee;
            --dark-pink: #ff3b6b;
            --text-dark: #2b1a1a;
            --text-muted: #6b4950;
            --white: #ffffff;
        }

        * { 
            box-sizing: border-box; 
            margin: 0; 
            padding: 0; 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
        }

        .announcements-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 24px;
        }

        .page-header {
            text-align: center;
            margin-bottom: 32px;
        }

        .page-title {
            font-size: 2.5rem;
            font-weight: 800;
            color: var(--text-dark);
            margin-bottom: 12px;
            text-shadow: 2px 2px 4px rgba(255, 107, 139, 0.2);
        }

        .announcements-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 32px;
            margin-bottom: 32px;
        }

        .announcement-card {
            background: var(--white);
            border-radius: 20px;
            padding: 32px;
            position: relative;
            overflow: hidden;
            box-shadow: 0 15px 40px -10px rgba(255, 107, 139, 0.25);
            border: 2px solid rgba(255, 107, 139, 0.1);
            transition: all 0.3s ease;
        }

        .announcement-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 25px 50px -15px rgba(255, 107, 139, 0.35);
        }

        /* Pink background box behind each card */
        .announcement-card::before {
            content: '';
            position: absolute;
            top: -20px;
            right: -20px;
            width: 120px;
            height: 120px;
            background: var(--primary-pink);
            border-radius: 50%;
            opacity: 0.15;
            z-index: 0;
        }

        .announcement-card::after {
            content: '';
            position: absolute;
            bottom: -30px;
            left: -30px;
            width: 150px;
            height: 150px;
            background: var(--primary-pink);
            border-radius: 50%;
            opacity: 0.1;
            z-index: 0;
        }

        .announcement-content-wrapper {
            position: relative;
            z-index: 1;
        }

        .announcement-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 16px;
            margin-bottom: 20px;
        }

        .announcement-type {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 16px;
            border-radius: 24px;
            font-size: 0.9rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            background: var(--primary-pink);
            color: var(--white);
            box-shadow: 0 4px 12px rgba(255, 107, 139, 0.3);
        }

        .announcement-date {
            color: var(--text-muted);
            font-size: 14px;
            font-weight: 600;
            background: var(--light-pink);
            padding: 10px 16px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(255, 107, 139, 0.1);
        }

        .announcement-title {
            font-size: 1.5rem;
            font-weight: 800;
            color: var(--text-dark);
            margin-bottom: 16px;
            line-height: 1.3;
            letter-spacing: -0.5px;
        }

        .announcement-content {
            color: var(--text-dark);
            line-height: 1.7;
            margin-bottom: 24px;
            font-size: 1rem;
            background: var(--light-pink);
            padding: 20px;
            border-radius: 16px;
            border-left: 4px solid var(--primary-pink);
        }

        .announcement-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 16px;
            border-top: 2px solid var(--light-pink);
        }

        .announcement-author {
            display: flex;
            align-items: center;
            gap: 12px;
            color: var(--text-dark);
            font-size: 0.95rem;
            font-weight: 700;
        }

        .author-avatar {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary-pink), var(--dark-pink));
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 14px;
            font-weight: bold;
            box-shadow: 0 4px 12px rgba(255, 107, 139, 0.3);
        }

        .announcement-actions {
            display: flex;
            gap: 16px;
        }

        .action-btn {
            padding: 12px 20px;
            border-radius: 14px;
            font-size: 0.95rem;
            font-weight: 700;
            cursor: pointer;
            border: none;
            transition: all 0.3s ease;
            min-width: 120px;
            text-align: center;
        }

        .btn-read {
            background: linear-gradient(135deg, var(--primary-pink), var(--dark-pink));
            color: white;
            box-shadow: 0 8px 20px rgba(255, 107, 139, 0.4);
        }

        .btn-read:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 25px rgba(255, 107, 139, 0.5);
        }

        .btn-important {
            background: var(--light-pink);
            color: var(--text-dark);
            font-weight: 700;
            border: 2px solid var(--primary-pink);
        }

        .btn-important:hover {
            background: var(--white);
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(255, 107, 139, 0.2);
        }

        /* Empty state */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            background: var(--light-pink);
            border-radius: 20px;
            margin: 40px 0;
            border: 2px solid rgba(255, 107, 139, 0.2);
            position: relative;
            overflow: hidden;
        }

        .empty-state::before {
            content: '';
            position: absolute;
            top: -50px;
            right: -50px;
            width: 200px;
            height: 200px;
            background: var(--primary-pink);
            border-radius: 50%;
            opacity: 0.1;
        }

        .empty-icon {
            font-size: 3.5rem;
            color: var(--primary-pink);
            margin-bottom: 20px;
            text-shadow: 2px 2px 4px rgba(255, 107, 139, 0.2);
        }

        .empty-title {
            font-size: 1.8rem;
            font-weight: 800;
            color: var(--text-dark);
            margin-bottom: 12px;
        }

        .empty-message {
            color: var(--text-muted);
            font-size: 1.1rem;
            max-width: 500px;
            margin: 0 auto;
            line-height: 1.6;
        }

        /* Responsive design */
        @media (max-width: 768px) {
            .announcements-container {
                padding: 16px;
            }
            
            .page-title {
                font-size: 2rem;
            }
            
            .announcements-grid {
                grid-template-columns: 1fr;
                gap: 24px;
            }
            
            .announcement-card {
                padding: 24px;
            }
            
            .announcement-header {
                flex-direction: column;
                gap: 12px;
                align-items: flex-start;
            }
            
            .announcement-footer {
                flex-direction: column;
                gap: 16px;
                align-items: flex-start;
            }
            
            .announcement-actions {
                width: 100%;
                justify-content: space-between;
            }
            
            .action-btn {
                min-width: auto;
                flex: 1;
            }
        }

        @media (max-width: 480px) {
            .page-title {
                font-size: 1.8rem;
            }
            
            .announcement-title {
                font-size: 1.3rem;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="announcements-container">
        <!-- Page Header -->
        <div class="page-header">
            <h1 class="page-title">Company Announcements</h1>
        </div>

        <!-- Announcements Grid -->
        <div class="announcements-grid">
            <!-- Announcement 1 - Urgent -->
            <div class="announcement-card">
                <div class="announcement-content-wrapper">
                    <div class="announcement-header">
                        <span class="announcement-type">Urgent</span>
                        <div class="announcement-date">Dec 15, 2024</div>
                    </div>
                    <h3 class="announcement-title">Holiday Schedule Update</h3>
                    <div class="announcement-content">
                        Due to the upcoming holiday season, please note the following office closures: 
                        December 24-26 and December 31-January 2. All employees must submit time-off requests 
                        by December 10th.
                    </div>
                    <div class="announcement-footer">
                        <div class="announcement-author">
                            <div class="author-avatar">HR</div>
                            <span>Human Resources</span>
                        </div>
                        <div class="announcement-actions">
                            <button class="action-btn btn-important">Mark Important</button>
                            <button class="action-btn btn-read">Read Full</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Announcement 2 - General -->
            <div class="announcement-card">
                <div class="announcement-content-wrapper">
                    <div class="announcement-header">
                        <span class="announcement-type">General</span>
                        <div class="announcement-date">Dec 12, 2024</div>
                    </div>
                    <h3 class="announcement-title">New Employee Wellness Program</h3>
                    <div class="announcement-content">
                        We're excited to announce our new Employee Wellness Program starting January 2025! 
                        The program includes mental health resources, fitness subsidies, and wellness workshops.
                    </div>
                    <div class="announcement-footer">
                        <div class="announcement-author">
                            <div class="author-avatar">HR</div>
                            <span>Human Resources</span>
                        </div>
                        <div class="announcement-actions">
                            <button class="action-btn btn-read">Read Full</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Announcement 3 - Info -->
            <div class="announcement-card">
                <div class="announcement-content-wrapper">
                    <div class="announcement-header">
                        <span class="announcement-type">Info</span>
                        <div class="announcement-date">Dec 10, 2024</div>
                    </div>
                    <h3 class="announcement-title">Annual Performance Review</h3>
                    <div class="announcement-content">
                        The annual performance review cycle begins January 15th, 2025. Managers will receive 
                        training materials next week. Please ensure all project documentation is up to date.
                    </div>
                    <div class="announcement-footer">
                        <div class="announcement-author">
                            <div class="author-avatar">HR</div>
                            <span>Human Resources</span>
                        </div>
                        <div class="announcement-actions">
                            <button class="action-btn btn-read">Read Full</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Announcement 4 - Warning -->
            <div class="announcement-card">
                <div class="announcement-content-wrapper">
                    <div class="announcement-header">
                        <span class="announcement-type">Warning</span>
                        <div class="announcement-date">Dec 8, 2024</div>
                    </div>
                    <h3 class="announcement-title">Security Protocol Reminder</h3>
                    <div class="announcement-content">
                        Please remember to lock your computers when stepping away from your desk and never 
                        share your login credentials. Recent security audits have identified several instances.
                    </div>
                    <div class="announcement-footer">
                        <div class="announcement-author">
                            <div class="author-avatar">HR</div>
                            <span>Human Resources</span>
                        </div>
                        <div class="announcement-actions">
                            <button class="action-btn btn-read">Read Full</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Announcement 5 - General -->
            <div class="announcement-card">
                <div class="announcement-content-wrapper">
                    <div class="announcement-header">
                        <span class="announcement-type">General</span>
                        <div class="announcement-date">Dec 5, 2024</div>
                    </div>
                    <h3 class="announcement-title">Office Renovation Schedule</h3>
                    <div class="announcement-content">
                        The office renovation project will begin on January 10th, 2025. Work will be conducted 
                        in phases to minimize disruption. Department relocations will be communicated two weeks ahead.
                    </div>
                    <div class="announcement-footer">
                        <div class="announcement-author">
                            <div class="author-avatar">HR</div>
                            <span>Human Resources</span>
                        </div>
                        <div class="announcement-actions">
                            <button class="action-btn btn-read">Read Full</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Announcement 6 - Info -->
            <div class="announcement-card">
                <div class="announcement-content-wrapper">
                    <div class="announcement-header">
                        <span class="announcement-type">Info</span>
                        <div class="announcement-date">Dec 1, 2024</div>
                    </div>
                    <h3 class="announcement-title">Benefits Enrollment Period</h3>
                    <div class="announcement-content">
                        Open enrollment for 2025 benefits begins December 15th and ends January 15th. 
                        New health insurance options and retirement plan updates will be available.
                    </div>
                    <div class="announcement-footer">
                        <div class="announcement-author">
                            <div class="author-avatar">HR</div>
                            <span>Human Resources</span>
                        </div>
                        <div class="announcement-actions">
                            <button class="action-btn btn-read">Read Full</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Action button functionality
        document.querySelectorAll('.action-btn').forEach(button => {
            button.addEventListener('click', function () {
                const buttonText = this.textContent;
                if (buttonText.includes('Mark Important')) {
                    this.textContent = '✓ Important';
                    this.style.background = 'var(--light-pink)';
                    this.style.color = 'var(--text-dark)';
                } else if (buttonText.includes('Read Full')) {
                    // In a real implementation, this would open a modal or navigate to full announcement
                    alert('Full announcement content would be displayed here.');
                }
            });
        });
    </script>
</asp:Content>

