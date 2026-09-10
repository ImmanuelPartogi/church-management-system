<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Akses Belum Tersedia - Church Operations System</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Inter', system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }
        body {
            background-color: #f8fafc;
            color: #1e293b;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 1.5rem;
        }
        .card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 1rem;
            max-width: 480px;
            width: 100%;
            padding: 2.5rem 2rem;
            text-align: center;
            box-shadow: 0 10px 25px -5px rgba(15, 23, 42, 0.05), 0 8px 10px -6px rgba(15, 23, 42, 0.03);
        }
        .icon-container {
            width: 64px;
            height: 64px;
            margin: 0 auto 1.5rem auto;
            background-color: #fef3c7;
            border-radius: 1rem;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #d97706;
        }
        .icon-container svg {
            width: 32px;
            height: 32px;
        }
        .brand-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            padding: 0.25rem 0.75rem;
            background-color: #f1f5f9;
            color: #475569;
            border-radius: 9999px;
            font-size: 0.75rem;
            font-weight: 600;
            margin-bottom: 1rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        h1 {
            font-size: 1.35rem;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 0.75rem;
        }
        p.description {
            font-size: 0.925rem;
            color: #64748b;
            line-height: 1.6;
            margin-bottom: 1.5rem;
        }
        .code-pill {
            display: inline-block;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            padding: 0.25rem 0.6rem;
            border-radius: 0.375rem;
            font-family: monospace;
            font-size: 0.75rem;
            color: #64748b;
            margin-bottom: 2rem;
        }
        .actions {
            display: flex;
            flex-direction: column;
            gap: 0.75rem;
        }
        .btn-primary {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 100%;
            padding: 0.75rem 1.25rem;
            background-color: #2563eb;
            color: #ffffff;
            border: none;
            border-radius: 0.625rem;
            font-size: 0.875rem;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.15s ease;
        }
        .btn-primary:hover {
            background-color: #1d4ed8;
        }
        .btn-secondary {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 100%;
            padding: 0.75rem 1.25rem;
            background-color: #ffffff;
            color: #475569;
            border: 1px solid #cbd5e1;
            border-radius: 0.625rem;
            font-size: 0.875rem;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.15s ease;
        }
        .btn-secondary:hover {
            background-color: #f8fafc;
            color: #1e293b;
        }
        .footer-note {
            margin-top: 2rem;
            font-size: 0.8rem;
            color: #94a3b8;
        }
    </style>
</head>
<body>
    <div class="card">
        <div class="icon-container">
            <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
            </svg>
        </div>

        <div class="brand-badge">
            Church Operations System
        </div>

        <h1>{{ $title ?? 'Akses Keanggotaan Belum Tersedia' }}</h1>

        <p class="description">
            {{ $message ?? 'Akun Anda saat ini belum terhubung dengan keanggotaan gereja yang aktif, atau Anda belum memiliki izin untuk mengelola tenant gereja ini.' }}
        </p>

        @if (!empty($code))
            <div>
                <span class="code-pill">Status: {{ $code }}</span>
            </div>
        @endif

        <div class="actions">
            @auth
                <form method="POST" action="{{ url('/admin/logout') }}">
                    @csrf
                    <button type="submit" class="btn-primary">
                        Keluar & Masuk dengan Akun Lain
                    </button>
                </form>
            @else
                <a href="{{ url('/admin/login') }}" class="btn-primary">
                    Kembali ke Halaman Login
                </a>
            @endauth

            <a href="javascript:history.back()" class="btn-secondary">
                Kembali ke Halaman Sebelumnya
            </a>
        </div>

        <div class="footer-note">
            Silakan hubungi administrator gereja Anda untuk menetapkan peran dan penugasan tenant.
        </div>
    </div>
</body>
</html>
