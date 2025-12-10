#!/usr/bin/env python3
"""
Git Directory Exposure Scanner
For authorized security testing only

This tool tests for exposed .git directories on web applications.
Part of ASPI Red Team Exercise - Git Exposure PoC

Usage:
    python3 git_exposure_scanner.py <target_url>

Example:
    python3 git_exposure_scanner.py https://apidevportal.aspi-indonesia.or.id
"""

import requests
import sys
import argparse
from urllib.parse import urljoin
from datetime import datetime
import json

class GitExposureScanner:
    def __init__(self, target_url, timeout=10, verbose=False):
        self.target = target_url.rstrip('/')
        self.timeout = timeout
        self.verbose = verbose
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'GitExposureScanner/1.0 (Security Assessment)'
        })
        self.findings = []

    def log(self, message, level="INFO"):
        """Print log message if verbose"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        if self.verbose or level == "CRITICAL":
            prefix = {
                "INFO": "ℹ️",
                "SUCCESS": "✅",
                "WARNING": "⚠️",
                "CRITICAL": "🔴",
                "ERROR": "❌"
            }.get(level, "•")
            print(f"[{timestamp}] {prefix} {message}")

    def test_url(self, path):
        """Test if a URL is accessible"""
        url = urljoin(self.target, path)
        try:
            response = self.session.get(url, timeout=self.timeout, allow_redirects=False)
            return response.status_code, response.headers, response.text[:500]
        except requests.exceptions.RequestException as e:
            return None, None, str(e)

    def test_git_exposure(self):
        """Test for .git directory exposure"""
        self.log(f"Testing target: {self.target}", "INFO")
        self.log("=" * 60, "INFO")

        # Test robots.txt first
        self.log("Checking robots.txt for .git references...", "INFO")
        status, _, content = self.test_url('/robots.txt')
        if status == 200 and '.git' in content.lower():
            self.log("Found .git reference in robots.txt!", "WARNING")
            self.findings.append({
                "file": "robots.txt",
                "status": "reference_found",
                "severity": "INFO"
            })

        # Common git files to test
        git_files = [
            ('.git/HEAD', 'CRITICAL'),
            ('.git/config', 'CRITICAL'),
            ('.git/index', 'HIGH'),
            ('.git/description', 'MEDIUM'),
            ('.git/COMMIT_EDITMSG', 'MEDIUM'),
            ('.git/logs/HEAD', 'HIGH'),
            ('.git/logs/refs/heads/master', 'HIGH'),
            ('.git/logs/refs/heads/main', 'HIGH'),
            ('.git/refs/heads/master', 'HIGH'),
            ('.git/refs/heads/main', 'HIGH'),
            ('.git/refs/remotes/origin/HEAD', 'MEDIUM'),
            ('.git/packed-refs', 'MEDIUM'),
            ('.git/ORIG_HEAD', 'LOW'),
            ('.git/FETCH_HEAD', 'LOW'),
        ]

        self.log("\nTesting for accessible .git files...", "INFO")
        self.log("-" * 60, "INFO")

        vulnerable_count = 0

        for git_file, severity in git_files:
            status, headers, content = self.test_url(git_file)

            if status == 200:
                self.log(f"{git_file:<40} 🔴 EXPOSED ({status})", "CRITICAL")
                vulnerable_count += 1
                self.findings.append({
                    "file": git_file,
                    "status": "exposed",
                    "http_code": status,
                    "severity": severity,
                    "content_preview": content[:100] if content else None
                })
            elif status == 403:
                self.log(f"{git_file:<40} ⚠️  FORBIDDEN ({status})", "WARNING")
                self.findings.append({
                    "file": git_file,
                    "status": "forbidden",
                    "http_code": status,
                    "severity": "INFO"
                })
            elif self.verbose:
                self.log(f"{git_file:<40} ✅ NOT FOUND ({status})", "INFO")

        return vulnerable_count

    def generate_report(self):
        """Generate assessment report"""
        print("\n" + "=" * 60)
        print("GIT DIRECTORY EXPOSURE ASSESSMENT REPORT")
        print("=" * 60)
        print(f"\nTarget: {self.target}")
        print(f"Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"Findings: {len(self.findings)}")

        exposed = [f for f in self.findings if f['status'] == 'exposed']
        forbidden = [f for f in self.findings if f['status'] == 'forbidden']

        print(f"\n📊 RESULTS:")
        print(f"  • Exposed files: {len(exposed)}")
        print(f"  • Forbidden files: {len(forbidden)}")

        if exposed:
            print(f"\n🔴 VULNERABILITY CONFIRMED!")
            print(f"  Severity: CRITICAL (CVSS 7.5)")
            print(f"  Impact: Complete source code disclosure possible")
            print(f"\n  Exposed files:")
            for finding in exposed:
                print(f"    • {finding['file']} (Severity: {finding['severity']})")

            print(f"\n⚠️  RECOMMENDED ACTIONS:")
            print(f"  1. IMMEDIATELY block .git directory in web server config")
            print(f"  2. Remove .git directory from production servers")
            print(f"  3. Rotate ALL credentials that may be in repository")
            print(f"  4. Review git history for sensitive data")
            print(f"  5. Implement monitoring for .git access attempts")

        elif forbidden:
            print(f"\n⚠️  PARTIAL EXPOSURE DETECTED")
            print(f"  .git directory exists but access is restricted")
            print(f"  Recommendation: Remove .git from production")

        else:
            print(f"\n✅ NO VULNERABILITY DETECTED")
            print(f"  .git directory appears to be properly secured")

        print("\n" + "=" * 60)

        return {
            "target": self.target,
            "timestamp": datetime.now().isoformat(),
            "vulnerable": len(exposed) > 0,
            "findings": self.findings,
            "summary": {
                "exposed": len(exposed),
                "forbidden": len(forbidden),
                "total_findings": len(self.findings)
            }
        }

def main():
    parser = argparse.ArgumentParser(
        description='Git Directory Exposure Scanner - Authorized Testing Only',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  python3 git_exposure_scanner.py https://example.com
  python3 git_exposure_scanner.py https://example.com -v
  python3 git_exposure_scanner.py https://example.com -o report.json

WARNING: Use only on systems you have permission to test!
Unauthorized scanning may be illegal and unethical.
        '''
    )

    parser.add_argument('target', help='Target URL to scan')
    parser.add_argument('-v', '--verbose', action='store_true',
                       help='Verbose output')
    parser.add_argument('-o', '--output', help='Output JSON report to file')
    parser.add_argument('-t', '--timeout', type=int, default=10,
                       help='Request timeout in seconds (default: 10)')

    args = parser.parse_args()

    # Validate URL
    if not args.target.startswith(('http://', 'https://')):
        print("❌ Error: Target must start with http:// or https://")
        sys.exit(1)

    # Disclaimer
    print("""
╔══════════════════════════════════════════════════════════════╗
║           GIT DIRECTORY EXPOSURE SCANNER                     ║
║           For Authorized Security Testing Only               ║
╠══════════════════════════════════════════════════════════════╣
║  WARNING: Unauthorized use is illegal                        ║
║  Ensure you have written permission to test this system      ║
╚══════════════════════════════════════════════════════════════╝
    """)

    response = input("Do you have authorization to test this system? (yes/no): ")
    if response.lower() != 'yes':
        print("❌ Testing aborted - authorization required")
        sys.exit(1)

    # Run scanner
    scanner = GitExposureScanner(args.target, timeout=args.timeout, verbose=args.verbose)
    vulnerable_count = scanner.test_git_exposure()
    report = scanner.generate_report()

    # Save report if requested
    if args.output:
        with open(args.output, 'w') as f:
            json.dump(report, f, indent=2)
        print(f"\n📄 Report saved to: {args.output}")

    # Exit code based on findings
    sys.exit(1 if vulnerable_count > 0 else 0)

if __name__ == '__main__':
    main()
