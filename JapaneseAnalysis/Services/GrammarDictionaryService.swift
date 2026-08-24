//
//  GrammarDictionaryService.swift
//  JapaneseAnalysis
//
//  Created by 田芳 on R 8/08/06.
//

import Foundation

/// 精选日语语法字典（JLPT N1-N5 重点语法）
/// 规则：
/// - 只收录真正具有学习价值的语法（固定句型、接续表达、文法模式、惯用表达、复合语法）
/// - 排除普通助词（は、が、を、に、で、と、へ、も 等）
/// - 排除普通时态（た、ない、ます、です 等）
/// - 排除普通敬体
/// - 最多返回 3 个重点语法，按重要程度排序
enum GrammarDictionaryService {

    /// 全部精选语法库
    static let grammarPoints: [GrammarPoint] = GrammarDataN1N2.points + GrammarDataN3.points + GrammarDataN4N5.points

    // MARK: - 查找方法

    /// 在句子中查找匹配的重点语法（按重要程度排序，最多返回 3 个）
    static func findGrammarPoints(in sentence: String) -> [GrammarPoint] {
        var matches: [(grammar: GrammarPoint, range: Range<String.Index>, position: Int)] = []
        var matchedRanges: [Range<String.Index>] = []

        // 按 pattern 长度从长到短排序，避免短 pattern 优先匹配
        let sortedPoints = grammarPoints.sorted { $0.pattern.count > $1.pattern.count }

        for point in sortedPoints {
            var searchRange = sentence.startIndex..<sentence.endIndex

            while let range = sentence.range(of: point.pattern, options: .caseInsensitive, range: searchRange) {
                // 检查是否与已匹配的范围重叠
                let overlaps = matchedRanges.contains { existing in
                    existing.overlaps(range)
                }

                if !overlaps {
                    let position = sentence.distance(from: sentence.startIndex, to: range.lowerBound)
                    matches.append((grammar: point, range: range, position: position))
                    matchedRanges.append(range)

                    // 同一个语法在一个句子中只匹配一次
                    break
                } else {
                    // 跳过重叠区域继续查找
                    searchRange = range.upperBound..<sentence.endIndex
                }
            }
        }

        // 按重要程度排序：
        // 1. 难度越高（N1 > N5）越重要
        // 2. 出现位置越靠前越重要
        let sortedMatches = matches.sorted { a, b in
            // 先按 JLPT 难度降序（N1 最重要）
            if a.grammar.jlptLevel != b.grammar.jlptLevel {
                return a.grammar.jlptLevel.difficultyRank > b.grammar.jlptLevel.difficultyRank
            }
            // 相同难度按出现位置升序（靠前的优先）
            return a.position < b.position
        }

        // 最多返回 3 个
        return sortedMatches.prefix(3).map { $0.grammar }
    }
}
