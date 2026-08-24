//
//  GrammarDataN4N5.swift
//  JapaneseAnalysis
//
//  Created by 田芳 on R 8/08/06.
//

import Foundation

/// JLPT N4-N5 精选语法
enum GrammarDataN4N5 {

    static let points: [GrammarPoint] = [
        // ═══ N4 语法 ═══
        GrammarPoint(
            pattern: "てから",
            name: "〜てから",
            meaning: "做完...之后",
            usage: "动词て形 + から",
            explanation: "表示时间上的先后顺序：先做前面的动作，再做后面的动作。",
            examples: ["ご飯を食べてから、勉強する。", "家に帰ってから、シャワーを浴びる。", "日本に来てから、日本語が上手になった。"],
            sentenceRole: "时间条件部分",
            jlptLevel: .n4
        ),
        GrammarPoint(
            pattern: "なければ",
            name: "〜なければ（ならない）",
            meaning: "如果不...（就不行）",
            usage: "动词ない形去掉ない + なければ",
            explanation: "「なければ」本身表示「如果不...」，后面常省略「ならない」表示「必须」。",
            examples: ["行かなければ（ならない）。", "勉強しなければ（ならない）。"],
            sentenceRole: "谓语",
            jlptLevel: .n4
        ),
        GrammarPoint(
            pattern: "たら",
            name: "〜たら",
            meaning: "如果...、...的话",
            usage: "动词/形容词た形 + ら",
            explanation: "表示假设条件，是口语中最常用的条件表达。",
            examples: ["雨が降ったら、行かない。", "暇だったら、遊びに行こう。"],
            sentenceRole: "条件状语",
            jlptLevel: .n4
        ),
        GrammarPoint(
            pattern: "ば",
            name: "〜ば",
            meaning: "如果...就...",
            usage: "动词ば形",
            explanation: "表示假定条件「如果...的话」，也可表示一般规律。",
            examples: ["春になれば、桜が咲く。", "これがあれば大丈夫だ。"],
            sentenceRole: "条件状语",
            jlptLevel: .n4
        ),
        GrammarPoint(
            pattern: "ても",
            name: "〜ても",
            meaning: "即使...也...",
            usage: "动词て形 + も",
            explanation: "表示让步「即使做了...也...」。",
            examples: ["雨が降っても、出かける。", "言っても分からない。"],
            sentenceRole: "让步状语",
            jlptLevel: .n4
        ),
        GrammarPoint(
            pattern: "やすい",
            name: "〜やすい",
            meaning: "容易...（倾向）",
            usage: "动词ます形去掉ます + やすい",
            explanation: "表示容易发生某事或具有某倾向。",
            examples: ["この本は読みやすい。", "風邪を引きやすい。"],
            sentenceRole: "谓语",
            jlptLevel: .n4
        ),
        GrammarPoint(
            pattern: "にくい",
            name: "〜にくい",
            meaning: "难以...（困难）",
            usage: "动词ます形去掉ます + にくい",
            explanation: "表示不容易做某事。",
            examples: ["この字は読みにくい。", "話しにくい相手だ。"],
            sentenceRole: "谓语",
            jlptLevel: .n4
        ),
        GrammarPoint(
            pattern: "らしい",
            name: "〜らしい",
            meaning: "好像...（推测）/ 像...似的",
            usage: "普通形 + らしい",
            explanation: "表示基于传闻或外部信息的推测。",
            examples: ["明日は雨らしい。", "彼は日本人らしい。"],
            sentenceRole: "谓语",
            jlptLevel: .n4
        ),
        GrammarPoint(
            pattern: "そう",
            name: "〜そう（样态）",
            meaning: "看起来像要...",
            usage: "动词ます形去掉ます / 形容词词干 + そう",
            explanation: "表示根据外观或样子的推测。",
            examples: ["雨が降りそうだ。", "おいしそうなケーキだ。"],
            sentenceRole: "谓语",
            jlptLevel: .n4
        ),
        GrammarPoint(
            pattern: "とき",
            name: "〜とき",
            meaning: "...的时候",
            usage: "动词普通形/形容词 + とき",
            explanation: "表示做某个动作的时点。",
            examples: ["日本に行くとき、荷物を少なくする。", "寝るとき、電気を消す。"],
            sentenceRole: "时间状语",
            jlptLevel: .n4
        ),
        GrammarPoint(
            pattern: "として",
            name: "〜として",
            meaning: "作为...（身份/资格）",
            usage: "名词 + として",
            explanation: "表示以某身份、资格或立场来做某事。",
            examples: ["留学生として日本に来た。", "先生として働いている。"],
            sentenceRole: "身份状语",
            jlptLevel: .n4
        ),
        GrammarPoint(
            pattern: "すぎる",
            name: "〜すぎる",
            meaning: "太...、过于...",
            usage: "动词ます形去掉ます / 形容词词干 + すぎる",
            explanation: "表示程度超过正常范围。",
            examples: ["食べすぎた。", "この問題は難しすぎる。"],
            sentenceRole: "谓语",
            jlptLevel: .n4
        ),

        // ═══ N5 语法 ═══
        GrammarPoint(
            pattern: "ている",
            name: "〜ている",
            meaning: "正在...、持续状态",
            usage: "动词て形 + いる",
            explanation: "表示动作正在进行或状态的持续。",
            examples: ["今、勉強している。", "東京に住んでいる。"],
            sentenceRole: "谓语",
            jlptLevel: .n5
        ),
        GrammarPoint(
            pattern: "と言う",
            name: "〜と言う",
            meaning: "叫做...、说...",
            usage: "名词 + と言う",
            explanation: "表示名称或引用别人的话。",
            examples: ["これは「桜」と言う花です。", "彼は明日来ると言った。"],
            sentenceRole: "谓语",
            jlptLevel: .n5
        ),
        GrammarPoint(
            pattern: "つもり",
            name: "〜つもり",
            meaning: "打算...（意图）",
            usage: "动词普通形/原形 + つもり",
            explanation: "表示自己的打算或意图。",
            examples: ["来年、日本へ行くつもりだ。", "結婚するつもりはない。"],
            sentenceRole: "谓语",
            jlptLevel: .n5
        ),
    ]
}
