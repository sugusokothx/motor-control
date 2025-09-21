#!/bin/bash
#
# このシミュレーションを実行するためのスクリプト

echo "シミュレーションを開始します..."

PYTHONPATH=src python examples/run_pmsm_current_vector.py

echo "シミュレーションが完了しました。"