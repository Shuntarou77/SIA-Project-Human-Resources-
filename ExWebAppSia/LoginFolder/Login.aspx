<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="ExWebAppSia.LoginFolder.Login"
    Async="true" %>

    <!DOCTYPE html>
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
                background: linear-gradient(135deg, #FCFAF9 0%, #FFFFFF 50%, #F8ECEB 100%);
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 20px;
                position: relative;
                overflow: hidden;
            }

            /* Animated Background Elements */
            body::before,
            body::after {
                content: '';
                position: absolute;
                border-radius: 50%;
                background: linear-gradient(135deg, rgba(163, 106, 102, 0.1), rgba(196, 154, 153, 0.1));
                animation: float 6s ease-in-out infinite;
            }

            body::before {
                width: 400px;
                height: 400px;
                top: -100px;
                right: -100px;
                animation-delay: 0s;
            }

            body::after {
                width: 300px;
                height: 300px;
                bottom: -80px;
                left: -80px;
                animation-delay: 3s;
            }

            @keyframes float {

                0%,
                100% {
                    transform: translateY(0) rotate(0deg);
                }

                50% {
                    transform: translateY(-30px) rotate(180deg);
                }
            }

            .login-container {
                background-color: white;
                border-radius: 24px;
                box-shadow: 0 16px 48px rgba(163, 106, 102, 0.15);
                overflow: hidden;
                width: 100%;
                max-width: 440px;
                animation: slideIn 0.6s cubic-bezier(0.34, 1.56, 0.64, 1);
                border: 1px solid #F0EEEE;
                position: relative;
                z-index: 1;
            }

            @keyframes slideIn {
                from {
                    opacity: 0;
                    transform: translateY(-40px) scale(0.95);
                }

                to {
                    opacity: 1;
                    transform: translateY(0) scale(1);
                }
            }

            .login-header {
                background: linear-gradient(135deg, #A36A66, #C49A99);
                padding: 48px 36px;
                text-align: center;
                color: white;
                position: relative;
                overflow: hidden;
            }

            .login-header::before {
                content: '';
                position: absolute;
                top: -50%;
                left: -50%;
                width: 200%;
                height: 200%;
                background: radial-gradient(circle, rgba(255, 255, 255, 0.1) 0%, transparent 70%);
                animation: pulse 4s ease-in-out infinite;
            }

            .login-logo {
                width: 260px;
                height: 140px;
                background-color: white;
                border-radius: 50%;
                margin: 0 auto 24px;
                display: flex;
                align-items: center;
                justify-content: center;
                box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
                position: relative;
                animation: bounce 2s ease-in-out infinite;
            }

            .login-logo svg {
                width: 48px;
                height: 48px;
                fill: #A36A66;
            }

            @keyframes bounce {

                0%,
                100% {
                    transform: translateY(0);
                }

                50% {
                    transform: translateY(-10px);
                }
            }

            .login-title {
                font-size: 32px;
                font-weight: 800;
                margin-bottom: 8px;
                position: relative;
                letter-spacing: 0.5px;
            }

            .login-subtitle {
                font-size: 15px;
                opacity: 0.95;
                font-weight: 500;
                position: relative;
            }

            .login-body {
                padding: 44px 36px;
            }

            .form-group {
                margin-bottom: 24px;
                position: relative;
            }

            .form-label {
                display: block;
                color: #6B4F4E;
                font-weight: 700;
                margin-bottom: 10px;
                font-size: 14px;
                letter-spacing: 0.3px;
                text-transform: uppercase;
            }

            .input-with-icon {
                position: relative;
            }

            .input-icon {
                position: absolute;
                left: 16px;
                top: 50%;
                transform: translateY(-50%);
                color: #B8A19F;
                transition: all 0.3s ease;
            }

            .input-icon svg {
                width: 20px;
                height: 20px;
                fill: currentColor;
            }

            .form-control {
                width: 100%;
                padding: 15px 20px 15px 50px;
                border: 2px solid #F0EEEE;
                border-radius: 12px;
                font-size: 15px;
                transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                background-color: #F8F6F5;
            }

            .form-control:focus {
                outline: none;
                border-color: #A36A66;
                background-color: white;
                box-shadow: 0 0 0 4px rgba(163, 106, 102, 0.1);
            }

            .form-control:focus+.input-icon {
                color: #A36A66;
            }

            .form-control::placeholder {
                color: #B8A19F;
            }

            .remember-forgot {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 28px;
                font-size: 14px;
            }

            .remember-me {
                display: flex;
                align-items: center;
                color: #6B4F4E;
                font-weight: 500;
            }

            .remember-me input[type="checkbox"] {
                margin-right: 8px;
                width: 20px;
                height: 20px;
                cursor: pointer;
                accent-color: #A36A66;
            }

            .forgot-link {
                color: #A36A66;
                text-decoration: none;
                font-weight: 700;
                transition: all 0.3s ease;
            }

            .forgot-link:hover {
                color: #8B5A58;
                text-decoration: underline;
            }

            .btn-login {
                width: 100%;
                padding: 16px;
                background: linear-gradient(135deg, #A36A66, #8B5A58);
                color: white;
                border: none;
                border-radius: 12px;
                font-size: 16px;
                font-weight: 800;
                cursor: pointer;
                transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
                box-shadow: 0 6px 20px rgba(163, 106, 102, 0.25);
                letter-spacing: 0.5px;
                text-transform: uppercase;
                position: relative;
                overflow: hidden;
            }

            .btn-login::before {
                content: '';
                position: absolute;
                top: 50%;
                left: 50%;
                width: 0;
                height: 0;
                border-radius: 50%;
                background: rgba(255, 255, 255, 0.2);
                transform: translate(-50%, -50%);
                transition: width 0.6s, height 0.6s;
            }

            .btn-login:hover::before {
                width: 300px;
                height: 300px;
            }

            .btn-login:hover {
                transform: translateY(-3px);
                box-shadow: 0 12px 32px rgba(163, 106, 102, 0.35);
            }

            .btn-login:active {
                transform: translateY(-1px);
            }

            .error-message {
                background: linear-gradient(135deg, #FEE2E2, #FECACA);
                color: #991B1B;
                padding: 14px 18px;
                border-radius: 12px;
                margin-bottom: 24px;
                display: none;
                border-left: 4px solid #DC2626;
                font-size: 14px;
                font-weight: 600;
                animation: shake 0.5s ease, slideInDown 0.5s ease;
            }

            .error-message.show {
                display: flex;
                align-items: center;
                gap: 12px;
            }

            .error-message svg {
                width: 20px;
                height: 20px;
                fill: #DC2626;
                flex-shrink: 0;
            }

            @keyframes shake {

                0%,
                100% {
                    transform: translateX(0);
                }

                25% {
                    transform: translateX(-12px);
                }

                75% {
                    transform: translateX(12px);
                }
            }

            .login-footer {
                text-align: center;
                padding: 24px 36px 32px;
                color: #9B7D7B;
                font-size: 13px;
                background: #F8F6F5;
            }

            .login-footer strong {
                color: #A36A66;
                font-weight: 700;
            }

            /* Loading State */
            .btn-login.loading {
                pointer-events: none;
                opacity: 0.7;
            }

            .btn-login.loading::after {
                content: '';
                position: absolute;
                width: 20px;
                height: 20px;
                top: 50%;
                left: 50%;
                margin-left: -10px;
                margin-top: -10px;
                border: 3px solid rgba(255, 255, 255, 0.3);
                border-top-color: white;
                border-radius: 50%;
                animation: spin 0.8s linear infinite;
            }

            @keyframes spin {
                to {
                    transform: rotate(360deg);
                }
            }

            /* Responsive */
            @media (max-width: 480px) {
                .login-container {
                    border-radius: 20px;
                }

                .login-header {
                    padding: 36px 24px;
                }

                .login-body {
                    padding: 32px 24px;
                }

                .login-title {
                    font-size: 28px;
                }

                .login-logo {
                    width: 72px;
                    height: 72px;
                    background-color: white;
                    border-radius: 50%;
                    margin: 0 auto 24px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    /* outer drop shadow */
                    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
                    /* visible border around the circle */
                    border: 4px solid rgba(163, 106, 102, 0.12);
                    /* subtle inner ring for depth */
                    outline: 2px solid rgba(255, 255, 255, 0.6);
                    position: relative;
                    animation: bounce 2s ease-in-out infinite;
                    overflow: hidden;
                }

                /* SVG sizing */
                .login-logo svg {
                    width: 72px;
                    height: 72px;
                    fill: #A36A66;
                    display: block;
                }

                /* Image sizing when using asp:Image */
                .login-logo-img {
                    width: 72px;
                    height: 72px;
                    object-fit: contain;
                    display: block;
                    background: transparent;
                }

                /* Responsive adjustments */
                @media (max-width: 480px) {
                    .login-logo {
                        width: 100px;
                        height: 100px;
                        border-width: 3px;
                        /* slightly thinner on small screens */
                        outline-width: 1px;
                    }

                    .login-logo svg,
                    .login-logo-img {
                        width: 56px;
                        height: 56px;
                    }
                }
            }
        </style>
    </head>

    <body>
        <form id="form1" runat="server">
            <div class="login-container">
                <div class="login-header">
                    <div class="login-logo">
                        <asp:Image ID="imgLogo" runat="server" ImageUrl="~/images/shessentials-logo.png"
                            CssClass="login-logo-img" AlternateText="Essentials Beauty Logo" />
                    </div>
                    <div class="login-title">Welcome Back</div>
                    <div class="login-subtitle">HR Management System</div>
                </div>

                <div class="login-body">
                    <div id="errorMessage" class="error-message" runat="server">
                        <svg viewBox="0 0 24 24">
                            <path
                                d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z" />
                        </svg>
                        <asp:Literal ID="litError" runat="server"></asp:Literal>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Username</label>
                        <div class="input-with-icon">
                            <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control"
                                placeholder="Enter your username" autocomplete="username"></asp:TextBox>
                            <div class="input-icon">
                                <svg viewBox="0 0 24 24">
                                    <path
                                        d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z" />
                                </svg>
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Password</label>
                        <div class="input-with-icon">
                            <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control"
                                placeholder="Enter your password" autocomplete="current-password"></asp:TextBox>
                            <div class="input-icon">
                                <svg viewBox="0 0 24 24">
                                    <path
                                        d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zM9 8V6c0-1.66 1.34-3 3-3s3 1.34 3 3v2H9z" />
                                </svg>
                            </div>
                        </div>
                    </div>

                    <div class="remember-forgot">
                        <label class="remember-me">
                            <asp:CheckBox ID="chkRememberMe" runat="server" />
                            Remember me
                        </label>
                        <a href="ForgotPassword.aspx" class="forgot-link">Forgot Password?</a>
                    </div>

                    <asp:Button ID="btnLogin" runat="server" Text="Login" CssClass="btn-login"
                        OnClick="btnLogin_Click" />
                </div>

                <div class="login-footer">
                    © 2025 <strong>Essentials Beauty</strong> HR System. All rights reserved.
                </div>
            </div>
        </form>

        <script>
            // Add loading state to login button
            document.getElementById('<%= btnLogin.ClientID %>').addEventListener('click', function (e) {
                this.classList.add('loading');
            });

            // Update Forgot Password link with current username
            const usernameInput = document.getElementById('<%= txtUsername.ClientID %>');
            const forgotLink = document.querySelector('.forgot-link');
            
            if (usernameInput && forgotLink) {
                usernameInput.addEventListener('input', function() {
                    const username = this.value.trim();
                    if (username) {
                        forgotLink.href = 'ForgotPassword.aspx?email=' + encodeURIComponent(username);
                    } else {
                        forgotLink.href = 'ForgotPassword.aspx';
                    }
                });
                
                // Initialize link if there's a pre-filled username (e.g. from Remember Me)
                if (usernameInput.value.trim()) {
                    forgotLink.href = 'ForgotPassword.aspx?email=' + encodeURIComponent(usernameInput.value.trim());
                }
            }

            // Focus animation for inputs
            const inputs = document.querySelectorAll('.form-control');
            inputs.forEach(input => {
                input.addEventListener('focus', function () {
                    this.parentElement.style.transform = 'scale(1.02)';
                    this.parentElement.style.transition = 'transform 0.3s ease';
                });
                input.addEventListener('blur', function () {
                    this.parentElement.style.transform = 'scale(1)';
                });
            });
        </script>
    </body>

    </html>