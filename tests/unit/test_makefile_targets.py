import os
import shutil
import subprocess

import pytest


@pytest.fixture
def clean_audit():
    """Ensure .audit directory is clean before/after tests."""
    audit_dir = ".audit"
    if os.path.exists(audit_dir):
        shutil.rmtree(audit_dir)
    yield
    # Cleanup after test if needed
    # shutil.rmtree(audit_dir, ignore_errors=True)

def test_make_help():
    """Verify 'make help' runs successfully."""
    result = subprocess.run(["make", "help"], capture_output=True, text=True)
    assert result.returncode == 0
    assert "help" in result.stdout

def test_make_ml5_init(clean_audit):
    """Verify 'make ml5-init' creates the scorecard."""
    result = subprocess.run(["make", "ml5-init"], capture_output=True, text=True)
    assert result.returncode == 0
    assert os.path.exists(".audit/maturity-level-5-scorecard.yml")

def test_make_refresh_readme():
    """Verify 'make refresh-readme' executes."""
    # Ensure .audit exists
    os.makedirs(".audit", exist_ok=True)
    result = subprocess.run(["make", "refresh-readme"], capture_output=True, text=True)
    assert result.returncode == 0

def test_validate_scripts_executable():
    """Ensure all core scripts are executable."""
    scripts = [
        "scripts/validate-ml5-scorecard.sh",
        "scripts/audit-canon.sh",
        "scripts/validate.sh"
    ]
    for script in scripts:
        assert os.access(script, os.X_OK), f"{script} is not executable"
