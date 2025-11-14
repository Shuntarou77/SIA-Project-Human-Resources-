<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="ExWebAppSia.LoginFolder.Login" Async="true" %><!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>HR System - Login</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #FF9999 0%, #FFC6C5 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .login-container {
            background-color: white;
            border-radius: 20px;
            box-shadow: 0 10px 40px rgba(139, 0, 0, 0.2);
            overflow: hidden;
            width: 100%;
            max-width: 400px;
            animation: slideIn 0.5s ease-out;
        }

        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(-30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .login-header {
            background: linear-gradient(135deg, #8B0000 0%, #FF9999 100%);
            padding: 40px 30px;
            text-align: center;
            color: white;
        }

        .login-logo {
            width: 80px;
            height: 80px;
            background-color: white;
            border-radius: 50%;
            margin: 0 auto 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
        }

        .login-title {
            font-size: 28px;
            font-weight: bold;
            margin-bottom: 5px;
        }

        .login-subtitle {
            font-size: 14px;
            opacity: 0.9;
        }

        .login-body {
            padding: 40px 30px;
        }

        .form-group {
            margin-bottom: 25px;
        }

        .form-label {
            display: block;
            color: #8B0000;
            font-weight: 600;
            margin-bottom: 8px;
            font-size: 14px;
        }

        .form-control {
            width: 100%;
            padding: 14px 18px;
            border: 2px solid #FFC6C5;
            border-radius: 10px;
            font-size: 15px;
            transition: all 0.3s ease;
            background-color: #FFF5F5;
        }

        .form-control:focus {
            outline: none;
            border-color: #FF9999;
            background-color: white;
            box-shadow: 0 0 0 3px rgba(255, 153, 153, 0.1);
        }

        .form-control::placeholder {
            color: #999;
        }

        .remember-forgot {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            font-size: 14px;
        }

        .remember-me {
            display: flex;
            align-items: center;
            color: #666;
        }

        .remember-me input[type="checkbox"] {
            margin-right: 8px;
            width: 18px;
            height: 18px;
            cursor: pointer;
        }

        .forgot-link {
            color: #8B0000;
            text-decoration: none;
            font-weight: 600;
        }

        .forgot-link:hover {
            text-decoration: underline;
        }

        .btn-login {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #8B0000 0%, #FF9999 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(139, 0, 0, 0.3);
        }

        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(139, 0, 0, 0.4);
        }

        .btn-login:active {
            transform: translateY(0);
        }

        .error-message {
            background-color: #FFEBEE;
            color: #D32F2F;
            padding: 12px 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: none;
            border-left: 4px solid #D32F2F;
            font-size: 14px;
        }

        .error-message.show {
            display: block;
            animation: shake 0.3s ease;
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-10px); }
            75% { transform: translateX(10px); }
        }

        .login-footer {
            text-align: center;
            padding: 20px 30px 30px;
            color: #666;
            font-size: 13px;
        }

        /* Responsive */
        @media (max-width: 480px) {
            .login-container {
                border-radius: 15px;
            }

            .login-header {
                padding: 30px 20px;
            }

            .login-body {
                padding: 30px 20px;
            }

            .login-title {
                font-size: 24px;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="login-container">
            <div class="login-header">
                <div class="login-logo">👤</div>
                <div class="login-title">Welcome Back</div>
                <div class="login-subtitle">HR Management System</div>
            </div>

            <div class="login-body">
                <div id="errorMessage" class="error-message" runat="server">
                    <asp:Literal ID="litError" runat="server"></asp:Literal>
                </div>

                <div class="form-group">
                    <label class="form-label">Username</label>
                    <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" 
                        placeholder="Enter your username" autocomplete="username"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label class="form-label">Password</label>
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" 
                        placeholder="Enter your password" autocomplete="current-password"></asp:TextBox>
                </div>

                <div class="remember-forgot">
                    <label class="remember-me">
                        <asp:CheckBox ID="chkRememberMe" runat="server" />
                        Remember me
                    </label>
                    <a href="#" class="forgot-link">Forgot Password?</a>
                </div>

                <asp:Button ID="btnLogin" runat="server" Text="Login" CssClass="btn-login" 
                    OnClick="btnLogin_Click" />
            </div>

            <div class="login-footer">
                © 2025 HR Management System. All rights reserved.
            </div>
        </div>
    </form>
</body>
</html>