/**
 * 歌词组件公共计算工具
 * V1/V2 组件共享的纯计算逻辑，保证两版行为一致且只需维护一处
 */

/** 生成歌词行的唯一 key（前2字+后2字+索引） */
export function generateLyricKey(text: string, index: number): string {
  const len = text.length;
  if (len <= 4) {
    return `${text}_${index}`;
  }
  const prefix = text.slice(0, 2);
  const suffix = text.slice(-2);
  return `${prefix}${suffix}_${index}`;
}

/**
 * 计算目标行居中时每行的 Y 位置（前缀和，O(n)）
 *
 * @param itemHeights 每行高度（不足时按 fallbackLineHeight 兜底）
 * @param targetIndex 需要居中到 targetY 的行索引；越界或 -1 时不添加高亮额外间距
 * @param targetY 高亮锚点 Y 坐标（容器高度 × highlightPositionRatio）
 * @param lineSpacing 普通行间距
 * @param highlightLineSpacing 高亮行两侧额外间距
 * @param fallbackLineHeight 高度缺失时的兜底行高
 * @returns 每行中心 Y 位置数组
 */
export function calculateLyricsItemYPositions(
  itemHeights: number[],
  targetIndex: number,
  targetY: number,
  lineSpacing: number,
  highlightLineSpacing: number,
  fallbackLineHeight: number
): number[] {
  const n = itemHeights.length;
  // 越界索引（含 -1）视为无高亮行，不添加高亮额外间距
  const highlightIndex = targetIndex >= 0 && targetIndex < n ? targetIndex : -1;

  // 第一遍：计算不带高亮间距的裸中心位置（前缀和）
  const positions: number[] = new Array(n);
  let y = 0;
  for (let i = 0; i < n; i++) {
    const height = itemHeights[i] ?? fallbackLineHeight;
    positions[i] = y + height / 2;
    y += height + lineSpacing;
  }
  // 与 V1 原实现一致：无高亮行时锚点取兜底行高的一半
  const highlightCenterY = highlightIndex >= 0 ? positions[highlightIndex] : fallbackLineHeight / 2;

  // 第二遍：整体平移到 targetY，并仅在高亮行两侧插入额外间距
  for (let i = 0; i < n; i++) {
    let extra = 0;
    if (highlightIndex >= 0) {
      if (i > highlightIndex) {
        // 高亮行下方间距
        extra = highlightLineSpacing;
      } else if (i < highlightIndex) {
        // 高亮行上方间距
        extra = -highlightLineSpacing;
      }
    }
    positions[i] = targetY + (positions[i] + extra - highlightCenterY);
  }
  return positions;
}

/**
 * 计算限位后的手动偏移（防止拖出第一行上方/最后一行下方）
 *
 * @returns [lower 限制, upper 限制]；lyrics 为空时返回 null
 */
export function calculateManualOffsetLimits(
  itemYPositions: number[],
  targetY: number
): number[] | null {
  if (itemYPositions.length === 0) {
    return null;
  }
  const firstY = itemYPositions[0] ?? 0;
  const lastY = itemYPositions[itemYPositions.length - 1] ?? 0;
  const pullDownLimit = targetY - firstY;
  const pushUpLimit = targetY - lastY;
  return [Math.min(pullDownLimit, pushUpLimit), Math.max(pullDownLimit, pushUpLimit)];
}

/**
 * 二分查找距 targetY 最近的行索引（手动滑动时确定高亮行）
 *
 * @returns 最近的行索引；itemYPositions 为空时返回 -1
 */
export function findNearestHighlightIndex(itemYPositions: number[], manualOffset: number, targetY: number): number {
  const n = itemYPositions.length;
  if (n === 0) {
    return -1;
  }

  let left = 0;
  let right = n - 1;
  while (left < right) {
    const mid = Math.floor((left + right) / 2);
    const midY = (itemYPositions[mid] ?? 0) + manualOffset;
    if (midY < targetY) {
      left = mid + 1;
    } else {
      right = mid;
    }
  }

  const leftY = (itemYPositions[left] ?? 0) + manualOffset;
  const leftDist = Math.abs(leftY - targetY);
  if (left > 0) {
    const prevY = (itemYPositions[left - 1] ?? 0) + manualOffset;
    const prevDist = Math.abs(prevY - targetY);
    if (prevDist < leftDist) {
      left = left - 1;
    }
  }
  return left;
}
