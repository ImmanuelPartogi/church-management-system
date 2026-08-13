<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\FinanceAccountType;
use App\Http\Controllers\Controller;
use App\Http\Requests\FinancialTransparencyRequest;
use App\Http\Resources\Api\FinancialTransparencyResource;
use App\Models\FinancialTransaction;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class FinancialTransparencyController extends Controller
{
    /**
     * Display aggregated public financial transparency report.
     */
    public function index(FinancialTransparencyRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $from = $validated['from'] ?? now()->startOfYear()->format('Y-m-d');
        $to = $validated['to'] ?? now()->format('Y-m-d');

        $totalIncome = (float) FinancialTransaction::whereBetween('transaction_date', [$from, $to])
            ->where('type', FinanceAccountType::Income->value)
            ->sum('amount');

        $totalExpense = (float) FinancialTransaction::whereBetween('transaction_date', [$from, $to])
            ->where('type', FinanceAccountType::Expense->value)
            ->sum('amount');

        $netBalance = $totalIncome - $totalExpense;

        /** @var array<int, array{account_code: string, account_name: string, total_amount: float}> $incomeBreakdown */
        $incomeBreakdown = DB::table('financial_transactions')
            ->whereBetween('financial_transactions.transaction_date', [$from, $to])
            ->where('financial_transactions.type', FinanceAccountType::Income->value)
            ->join('chart_of_accounts', 'financial_transactions.chart_of_account_id', '=', 'chart_of_accounts.id')
            ->select(
                'chart_of_accounts.code as account_code',
                'chart_of_accounts.name as account_name',
                DB::raw('SUM(financial_transactions.amount) as total_amount')
            )
            ->groupBy('chart_of_accounts.code', 'chart_of_accounts.name')
            ->get()
            ->map(fn (object $item): array => [
                'account_code' => (string) $item->account_code,
                'account_name' => (string) $item->account_name,
                'total_amount' => (float) $item->total_amount,
            ])
            ->all();

        /** @var array<int, array{account_code: string, account_name: string, total_amount: float}> $expenseBreakdown */
        $expenseBreakdown = DB::table('financial_transactions')
            ->whereBetween('financial_transactions.transaction_date', [$from, $to])
            ->where('financial_transactions.type', FinanceAccountType::Expense->value)
            ->join('chart_of_accounts', 'financial_transactions.chart_of_account_id', '=', 'chart_of_accounts.id')
            ->select(
                'chart_of_accounts.code as account_code',
                'chart_of_accounts.name as account_name',
                DB::raw('SUM(financial_transactions.amount) as total_amount')
            )
            ->groupBy('chart_of_accounts.code', 'chart_of_accounts.name')
            ->get()
            ->map(fn (object $item): array => [
                'account_code' => (string) $item->account_code,
                'account_name' => (string) $item->account_name,
                'total_amount' => (float) $item->total_amount,
            ])
            ->all();

        $data = [
            'period' => [
                'from' => $from,
                'to' => $to,
            ],
            'summary' => [
                'total_income' => $totalIncome,
                'total_expense' => $totalExpense,
                'net_balance' => $netBalance,
            ],
            'income_breakdown' => $incomeBreakdown,
            'expense_breakdown' => $expenseBreakdown,
        ];

        return $this->jsonSuccess(new FinancialTransparencyResource($data), 'Financial transparency report retrieved successfully.');
    }
}
