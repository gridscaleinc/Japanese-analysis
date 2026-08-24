//
//  GrammarDataN1N2.swift
//  JapaneseAnalysis
//
//  Created by 田芳 on R 8/08/06.
//

import Foundation

/// JLPT N1-N2 精选语法
enum GrammarDataN1N2 {

    static let points: [GrammarPoint] = [
        // ═══ N1 语法 ═══
        GrammarPoint(
            pattern: "ざるを得ない",
            name: "〜ざるを得ない",
            meaning: "不得不...",
            usage: "动词ない形（去掉ない）+ ざるを得ない",
            explanation: "表示没有其他选择，只能那样做，带有无奈的语气。",
            examples: ["秘密を話さざるを得なかった。", "値上げせざるを得ない。"],
            sentenceRole: "谓语",
            jlptLevel: .n1
        ),
        GrammarPoint(
            pattern: "かねない",
            name: "〜かねない",
            meaning: "很可能造成不好的后果",
            usage: "动词ます形去掉ます + かねない",
            explanation: "表示有可能发生不好的事情，带有担心、警告的语气。",
            examples: ["そんなに働くと病気になりかねない。", "このままだと事故が起こりかねない。"],
            sentenceRole: "谓语",
            jlptLevel: .n1
        ),
        GrammarPoint(
            pattern: "ものの",
            name: "〜ものの",
            meaning: "虽然...但是...",
            usage: "动词普通形/形容词 + ものの",
            explanation: "表示让步转折，承认前项但结果不如预期。",
            examples: ["買ったものの、全然使っていない。", "行きたいものの、時間がない。"],
            sentenceRole: "转折部分",
            jlptLevel: .n1
        ),
        GrammarPoint(
            pattern: "を問わず",
            name: "〜を問わず",
            meaning: "无论...、不分...",
            usage: "名词 + を問わず",
            explanation: "表示不受某条件限制。常用于「男女を問わず」「年齢を問わず」。",
            examples: ["経験を問わず、誰でも応募できます。", "年齢を問わず参加できます。"],
            sentenceRole: "条件状语",
            jlptLevel: .n1
        ),
        GrammarPoint(
            pattern: "のみならず",
            name: "〜のみならず",
            meaning: "不仅...而且...",
            usage: "名词/普通形 + のみならず",
            explanation: "书面语，强调「不仅仅是前面的，后面的也一样」。",
            examples: ["品質のみならず、価格も優れている。", "子供のみならず大人も楽しめる。"],
            sentenceRole: "并列成分",
            jlptLevel: .n1
        ),
        GrammarPoint(
            pattern: "といっても",
            name: "〜といっても",
            meaning: "虽说...但是...",
            usage: "句子普通形 + といっても",
            explanation: "表示先承认前项，但实际程度没有那么高。",
            examples: ["留学生といっても、日本語はあまり話せない。", "安いといっても、万単位だ。"],
            sentenceRole: "让步转折",
            jlptLevel: .n1
        ),

        // ═══ N2 语法 ═══
        GrammarPoint(
            pattern: "わけにはいかない",
            name: "〜わけにはいかない",
            meaning: "不能...、不可以...",
            usage: "动词普通形 + わけにはいかない",
            explanation: "表示出于道义或社会规则，不能那样做。",
            examples: ["今日は大事な日だから、遅れるわけにはいかない。", "彼を助けないわけにはいかない。"],
            sentenceRole: "谓语",
            jlptLevel: .n2
        ),
        GrammarPoint(
            pattern: "に違いない",
            name: "〜に違いない",
            meaning: "一定...、肯定...",
            usage: "动词/形容词普通形 + に違いない",
            explanation: "表示说话人非常有把握的推测。",
            examples: ["あの人は日本人に違いない。", "彼は必ず成功するに違いない。"],
            sentenceRole: "谓语",
            jlptLevel: .n2
        ),
        GrammarPoint(
            pattern: "べきだ",
            name: "〜べきだ",
            meaning: "应该...（理应）",
            usage: "动词原形 + べきだ",
            explanation: "表示从道理上或常识上应该那样做。",
            examples: ["学生は勉強すべきだ。", "約束は守るべきだ。"],
            sentenceRole: "谓语",
            jlptLevel: .n2
        ),
        GrammarPoint(
            pattern: "つつある",
            name: "〜つつある",
            meaning: "正在逐渐...",
            usage: "动词ます形去掉ます + つつある",
            explanation: "表示某状态正在逐渐变化、发展的过程中。",
            examples: ["経済は回復しつつある。", "町は変わりつつある。"],
            sentenceRole: "谓语",
            jlptLevel: .n2
        ),
        GrammarPoint(
            pattern: "一方で",
            name: "〜一方で",
            meaning: "一方面...另一方面...",
            usage: "动词普通形 + 一方で",
            explanation: "表示同时存在的两个不同方面。",
            examples: ["便利になる一方で、問題もある。", "経済が発展する一方で、環境が悪化している。"],
            sentenceRole: "转折/并列",
            jlptLevel: .n2
        ),
        GrammarPoint(
            pattern: "だけに",
            name: "〜だけに",
            meaning: "正因为...所以更加...",
            usage: "名词/动词普通形 + だけに",
            explanation: "表示正因为前项的原因，后项更加突出。",
            examples: ["長年練習してきただけに、悔しい。", "期待が大きいだけに、失望も大きい。"],
            sentenceRole: "原因状语",
            jlptLevel: .n2
        ),
        GrammarPoint(
            pattern: "ばかりでなく",
            name: "〜ばかりでなく",
            meaning: "不仅...而且...",
            usage: "名词/普通形 + ばかりでなく",
            explanation: "和「だけでなく」同义，更书面。",
            examples: ["経済ばかりでなく、文化にも影響がある。", "日本ばかりでなく、世界でも有名だ。"],
            sentenceRole: "并列成分",
            jlptLevel: .n2
        ),
        GrammarPoint(
            pattern: "に限らず",
            name: "〜に限らず",
            meaning: "不仅限于...",
            usage: "名词 + に限らず",
            explanation: "表示范围不限于前项，后项也被包含。",
            examples: ["男性に限らず、女性も参加している。", "若者に限らず、年寄りも使う。"],
            sentenceRole: "范围状语",
            jlptLevel: .n2
        ),
        GrammarPoint(
            pattern: "どころか",
            name: "〜どころか",
            meaning: "岂止...、不但不...反而...",
            usage: "名词/普通形 + どころか",
            explanation: "表示强烈否定前项，实际程度更超乎预期。",
            examples: ["褒められるどころか、叱られた。", "漢字どころかひらがなも読めない。"],
            sentenceRole: "转折状语",
            jlptLevel: .n2
        ),
        GrammarPoint(
            pattern: "をはじめ",
            name: "〜をはじめ",
            meaning: "以...为首、主要的是...",
            usage: "名词 + をはじめ",
            explanation: "表示以前项为代表，列举典型例子。",
            examples: ["日本をはじめ、多くの国で使われている。", "社長をはじめ、社員全員が参加した。"],
            sentenceRole: "列举成分",
            jlptLevel: .n2
        ),
        GrammarPoint(
            pattern: "にしても",
            name: "〜にしても",
            meaning: "即使...也...",
            usage: "名词/动词普通形 + にしても",
            explanation: "表示即使站在前项的立场，后项也不成立。",
            examples: ["忙しいにしても、連絡くらいできるだろう。", "安いにしても、買いすぎだ。"],
            sentenceRole: "让步状语",
            jlptLevel: .n2
        ),
        GrammarPoint(
            pattern: "ものだ",
            name: "〜ものだ",
            meaning: "（感叹）真是...、（理所当然）就应该...",
            usage: "动词/形容词普通形 + ものだ",
            explanation: "表示感叹、感慨，或「本来就是那样的」道理。",
            examples: ["時間が経つのは早いものだ。", "子供は親の言うことを聞くものだ。"],
            sentenceRole: "谓语",
            jlptLevel: .n2
        ),
    ]
}
