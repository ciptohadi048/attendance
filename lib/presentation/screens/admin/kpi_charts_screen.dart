import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/admin_providers.dart';

class KpiChartsScreen extends ConsumerWidget {
  const KpiChartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpiAsync = ref.watch(weeklyKpiProvider);
    final hourlyAsync = ref.watch(hourlyDistributionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('KPI Charts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: kpiAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (kpiList) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Weekly attendance rate
            Text('Tingkat Kehadiran (7 Hari)',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 24, 8),
                child: SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      maxY: 100,
                      barGroups: List.generate(kpiList.length, (i) {
                        final d = kpiList[i];
                        final rate = d.total == 0
                            ? 0.0
                            : ((d.hadir + d.telat) / d.total * 100);
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: rate,
                              color: rate >= 80
                                  ? AppColors.success
                                  : rate >= 60
                                      ? AppColors.warning
                                      : AppColors.danger,
                              width: 18,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            getTitlesWidget: (v, _) => Text('${v.toInt()}%',
                                style: theme.textTheme.labelSmall),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 || i >= kpiList.length) {
                                return const SizedBox.shrink();
                              }
                              return Text(
                                DateFormat('E', 'id')
                                    .format(kpiList[i].date),
                                style: theme.textTheme.labelSmall,
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: AppColors.textMuted.withValues(alpha: 0.2),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Late trend (line chart)
            Text('Tren Keterlambatan (7 Hari)',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 24, 8),
                child: SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            kpiList.length,
                            (i) => FlSpot(
                                i.toDouble(), kpiList[i].telat.toDouble()),
                          ),
                          isCurved: true,
                          color: AppColors.warning,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.warning.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (v, _) => Text(
                                v.toInt().toString(),
                                style: theme.textTheme.labelSmall),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 || i >= kpiList.length) {
                                return const SizedBox.shrink();
                              }
                              return Text(
                                DateFormat('E', 'id')
                                    .format(kpiList[i].date),
                                style: theme.textTheme.labelSmall,
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: AppColors.textMuted.withValues(alpha: 0.2),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Hourly distribution
            Text('Distribusi Jam Clock-In (Hari Ini)',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            hourlyAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (hourly) {
                if (hourly.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text('Belum ada clock-in hari ini',
                            style: theme.textTheme.bodySmall),
                      ),
                    ),
                  );
                }
                final hours = hourly.keys.toList()..sort();
                final maxVal = hourly.values
                    .fold(0, (a, b) => a > b ? a : b)
                    .toDouble();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 24, 8),
                    child: SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          maxY: maxVal + 1,
                          barGroups: hours.map((h) {
                            return BarChartGroupData(
                              x: h,
                              barRods: [
                                BarChartRodData(
                                  toY: (hourly[h] ?? 0).toDouble(),
                                  color: AppColors.safetyOrange,
                                  width: 14,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            );
                          }).toList(),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: (v, _) => Text(
                                    v.toInt().toString(),
                                    style: theme.textTheme.labelSmall),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, _) => Text(
                                    '${v.toInt()}:00',
                                    style: theme.textTheme.labelSmall),
                              ),
                            ),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (_) => FlLine(
                              color:
                                  AppColors.textMuted.withValues(alpha: 0.2),
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
