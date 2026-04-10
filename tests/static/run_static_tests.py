#!/usr/bin/env python3
import sys
from pathlib import Path
sys.path.insert(0, '.')

from interpreter.input_model import Program
from interpreter.static_checks import run_static_checks
from interpreter.class_table import ClassTable

TEST_DIR = Path('../../tests/static')

for test_file in TEST_DIR.glob('*.test'):
    print(f"\n=== Testing {test_file.name} ===")
    try:
        xml_tree = etree.parse(test_file)
        program = Program.from_xml_tree(xml_tree.getroot())
        ct = ClassTable()
        run_static_checks(program, ct)
        print("✅ PASSED - no errors")
    except Exception as e:
        print(f"❌ FAILED: {e}")
