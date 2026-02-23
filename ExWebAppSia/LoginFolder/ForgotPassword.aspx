<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs"
    Inherits="ExWebAppSia.LoginFolder.ForgotPassword" Async="true" %>

    <!DOCTYPE html>
    <html xmlns="http://www.w3.org/1999/xhtml">

    <head runat="server">
        <title>Forgot Password - HR System</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #FCFAF9 0%, #FFFFFF 50%, #F8ECEB 100%);
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 20px;
            }

            .container {
                background-color: white;
                border-radius: 24px;
                box-shadow: 0 16px 48px rgba(163, 106, 102, 0.15);
                width: 100%;
                max-width: 440px;
                padding: 44px 36px;
                border: 1px solid #F0EEEE;
                animation: slideIn 0.6s cubic-bezier(0.34, 1.56, 0.64, 1);
            }

            @keyframes slideIn {
                from {
                    opacity: 0;
                    transform: translateY(-40px);
                }

                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            .title {
                color: #A36A66;
                font-size: 28px;
                font-weight: 800;
                margin-bottom: 12px;
                text-align: center;
            }

            .subtitle {
                color: #6B4F4E;
                font-size: 15px;
                margin-bottom: 32px;
                text-align: center;
                line-height: 1.5;
            }

            .form-group {
                margin-bottom: 24px;
            }

            .form-label {
                display: block;
                color: #6B4F4E;
                font-weight: 700;
                margin-bottom: 10px;
                font-size: 14px;
                text-transform: uppercase;
            }

            .form-control {
                width: 100%;
                padding: 15px 20px;
                border: 2px solid #F0EEEE;
                border-radius: 12px;
                font-size: 15px;
                background-color: #F8F6F5;
                transition: all 0.3s ease;
            }

            .form-control:focus {
                outline: none;
                border-color: #A36A66;
                background-color: white;
                box-shadow: 0 0 0 4px rgba(163, 106, 102, 0.1);
            }

            .btn-reset {
                width: 100%;
                padding: 16px;
                background: linear-gradient(135deg, #A36A66, #8B5A58);
                color: white;
                border: none;
                border-radius: 12px;
                font-size: 16px;
                font-weight: 800;
                cursor: pointer;
                transition: all 0.3s ease;
                box-shadow: 0 6px 20px rgba(163, 106, 102, 0.25);
                text-transform: uppercase;
                margin-bottom: 20px;
            }

            .btn-reset:hover {
                transform: translateY(-2px);
                box-shadow: 0 12px 32px rgba(163, 106, 102, 0.35);
            }

            .back-link {
                display: block;
                text-align: center;
                color: #A36A66;
                text-decoration: none;
                font-weight: 700;
                font-size: 14px;
            }

            .back-link:hover {
                text-decoration: underline;
            }

            .message {
                padding: 14px 18px;
                border-radius: 12px;
                margin-bottom: 24px;
                font-size: 14px;
                font-weight: 600;
                display: none;
            }

            .message.error {
                background-color: #FEE2E2;
                color: #991B1B;
                border-left: 4px solid #DC2626;
                display: block;
            }

            .message.success {
                background-color: #ECFDF5;
                color: #065F46;
                border-left: 4px solid #10B981;
                display: block;
            }
        </style>
    </head>

    <body>
        <form id="form1" runat="server">
            <div class="container">
                <h1 class="title">Forgot Password?</h1>
                <p class="subtitle">Enter your email address and we'll send you a link to reset your password.</p>

                <div id="pnlMessage" runat="server" class="message">
                    <asp:Literal ID="litMessage" runat="server"></asp:Literal>
                </div>

                <div id="pnlForm" runat="server">
                    <div class="form-group">
                        <label class="form-label">Email Address</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control"
                            placeholder="Enter your registered email"></asp:TextBox>
                    </div>

                    <asp:Button ID="btnSendLink" runat="server" Text="Send Reset Link" CssClass="btn-reset"
                        OnClick="btnSendLink_Click" />
                </div>

                <a href="Login.aspx" class="back-link">Back to Login</a>
            </div>
        </form>
    </body>

    </html>