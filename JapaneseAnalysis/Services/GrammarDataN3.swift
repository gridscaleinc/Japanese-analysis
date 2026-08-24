//
//  GrammarDataN3.swift
//  JapaneseAnalysis
//
//  Created by 田芳 on R 8/08/06.
//

import Foundation

/// JLPT N3 精选语法
enum GrammarDataN3 {

    static let points: [GrammarPoint] = [
        GrammarPoint(
            pattern: "てしまう",
            name: "〜てしまう",
            meaning: "（不自觉地）做了...（完了/遗憾）",
            usage: "动词て形 + しまう",
            explanation: "表示动作彻底完成，或带有遗憾、懊悔的语气。",
            examples: ["ケーキを全部食べてしまった。", "財布を忘れてしまった。"],
            sentenceRole: "谓语",
            jlptLevel: .n3
        ),
        GrammarPoint(
            pattern: "ておく",
            name: "〜ておく",
            meaning: "事先做好...",
            usage: "动词て形 + おく",
            explanation: "表示为了某种目的提前做好准备。",
            examples: ["明日の準備をしておく。", "冷蔵庫に入れておく。"],
            sentenceRole: "谓语",
            jlptLevel: .n3
        ),
        GrammarPoint(
            pattern: "てみる",
            name: "〜てみる",
            meaning: "试着...",
            usage: "动词て形 + みる",
            explanation: "表示尝试做某事，看看结果如何。",
            examples: ["日本語で話してみる。", "一度食べてみてください。"],
            sentenceRole: "谓语",
            jlptLevel: .n3
        ),
        GrammarPoint(
            pattern: "なければならない",
            name: "〜なければならない",
            meaning: "必须...（义务）",
            usage: "动词ない形去掉ない + なければならない",
            explanation: "表示法律、规则或道理上必须做某事。",
            examples: ["宿題をしなければならない。", "明日早く起きなければならない。"],
            sentenceRole: "谓语",
            jlptLevel: .n3
        ),
        GrammarPoint(
            pattern: "たほうがいい",
            name: "〜たほうがいい",
            meaning: "最好...（建议）",
            usage: "动词た形 + ほうがいい",
            explanation: "表示向对方提出建议或忠告。",
            examples: ["早く寝たほうがいいよ。", "病院に行ったほうがいい。"],
            sentenceRole: "谓语",
            jlptLevel: .n3
        ),
        GrammarPoint(
            pattern: "てはいけない",
            name: "〜てはいけない",
            meaning: "不可以...（禁止）",
            usage: "动词て形 + はいけない",
            explanation: "表示禁止、不允许做某事。",
            examples: ["ここで写真を撮ってはいけない。", "宿題を忘れてはいけない。"],
            sentenceRole: "谓语",
            jlptLevel: .n3
        ),
        GrammarPoint(
            pattern: "てもいい",
            name: "〜てもいい",
            meaning: "可以...（允许）",
            usage: "动词て形 + もいい",
            explanation: "表示允许或征求许可。",
            examples: ["ここに座ってもいいですか。", "好きなものを食べてもいいよ。"],
            sentenceRole: "谓语",
            jlptLevel: .n3
        ),
        GrammarPoint(
            pattern: "ために",
            name: "〜ために",
            meaning: "为了...（目的）/ 因为...（原因）",
            usage: "动词原形/名词の + ために",
            explanation: "表示目的（为了做某事）或原因（因为...）。",
            examples: ["日本語を勉強するために日本へ来た。", "事故のために遅れた。"],
            sentenceRole: "目的/原因状语",
            jlptLevel: .n3
        ),
        GrammarPoint(
            pattern: "のに",
            name: "〜のに",
            meaning: "明明...却...（转折）",
            usage: "动词/形容词普通形 + のに",
            explanation: "表示转折，带有遗憾、不满、意外的语气。",
            examples: ["勉強したのに、テストは難しかった。", "晴れているのに、傘を忘れた。"],
            sentenceRole: "转折部分",
            jlptLevel: .n3
        ),
        GrammarPoint(
            pattern: "ながら",
            name: "〜ながら",
            meaning: "一边...一边...",
            usage: "动词ます形去掉ます + ながら",
            explanation: "表示两个动作同时进行。",
            examples: ["音楽を聞きながら、勉強する。", "ご飯を食べながら、話す。"],
            sentenceRole: "伴随动作",
            jlptLevel: .n3
        ),
        GrammarPoint(
            pattern: "につれて",
            name: "〜につれて",
            meaning: "随着...",
            usage: "动词原形 + につれて",
            explanation: "表示随着前项变化，后项也渐渐变化。",
            examples: ["上手になるにつれて、面白くなる。", "日が暮れるにつれて、寒くなった。"],
            sentenceRole: "伴随状语",
            jlptLevel: .n3
        ),
        GrammarPoint(
            pattern: "にとって",
            name: "〜にとって",
            meaning: "对...来说",
            usage: "名词 + にとって",
            explanation: "表示从某个立场或角度来评判。",
            examples: ["私にとって、家族が一番大切だ。", "学生にとって、この本は参考になる。"],
            sentenceRole: "立场状语",
            jlptLevel: .n3
        ),
        GrammarPoint(
            pattern: "について",
            name: "〜について",
            meaning: "关于...",
            usage: "名词 + について",
            explanation: "表示就某话题展开讨论、说明。",
            examples: ["日本文化について研究している。", "この問題について話し合おう。"],
            sentenceRole: "对象状语",
            jlptLevel: .n3
        ),
        GrammarPoint(
            pattern: "によって",
            name: "〜によって",
            meaning: "根据...、因...而不同",
            usage: "名词 + によって",
            explanation: "表示原因、手段或根据情况不同结果不同。",
            examples: ["人によって考え方が違う。", "インターネットによって情報を得る。"],
            sentenceRole: "依据/手段状语",
            jlptLevel: .n3
        ),
        GrammarPoint(
            pattern: "に対して",
            name: "〜に対して",
            meaning: "对...、向...；与...相反",
            usage: "名词 + に対して",
            explanation: "表示动作的对象或与之对比。",
            examples: ["部長に対して感謝の気持ちを表した。", "昨日に対して今日は涼しい。"],
            sentenceRole: "对象状语",
            jlptLevel: .n3
        ),
        GrammarPoint(
            pattern: "ことになっている",
            name: "〜ことになっている",
            meaning: "按规定...、约定...",
            usage: "动词普通形 + ことになっている",
            explanation: "表示社会规则、约定或计划。",
            examples: ["9時までに出勤することになっている。", "来月から新しい制度を使うことになっている。"],
            sentenceRole: "谓语",
            jlptLevel: .n3
        ),
        GrammarPoint(
            pattern: "ことにする",
            name: "〜ことにする",
            meaning: "决定...（自己做决定）",
            usage: "动词普通形 + ことにする",
            explanation: "表示自己做出主观决定。",
            examples: ["毎日運動することにした。", "日本語を勉強することにする。"],
            sentenceRole: "谓语",
            jlptLevel: .n3
        ),
        GrammarPoint(
            pattern: "ようになる",
            name: "〜ようになる",
            meaning: "变得...、变成可以...",
            usage: "动词原形 + ようになる",
            explanation: "表示状态、能力或习惯的变化。",
            examples: ["日本語が話せるようになった。", "早起きするようになった。"],
            sentenceRole: "谓语",
            jlptLevel: .n3
        ),
    ]
}
