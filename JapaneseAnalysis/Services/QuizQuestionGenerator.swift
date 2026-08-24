//
//  QuizQuestionGenerator.swift
//  JapaneseAnalysis
//
//  Created by 田芳 on R 8/08/06.
//

import Foundation

/// 每日挑战题目生成器（内置 N2-N3 题库，随机组合）
/// 说明：当前使用本地题库实现动态出题，后续可接入 AI 生成
enum QuizQuestionGenerator {

    /// 生成一组每日挑战题（5 道：3 语法 + 2 词汇）
    static func generateDailyChallenge() -> [QuizQuestion] {
        let grammarQuestions = grammarPool.shuffled().prefix(3)
        let vocabularyQuestions = vocabularyPool.shuffled().prefix(2)

        var questions = grammarQuestions.map { createQuestion(from: $0) }
        questions += vocabularyQuestions.map { createQuestion(from: $0) }

        return questions.shuffled()
    }

    // MARK: - 题目构造

    private static func createQuestion(from pool: QuestionTemplate) -> QuizQuestion {
        let correct = pool.correctAnswer
        var wrongs = pool.wrongAnswers.shuffled()

        // 确保正好 4 个选项
        let optionsCount = 4
        while wrongs.count < optionsCount - 1 {
            wrongs.append("其他")
        }
        wrongs = Array(wrongs.prefix(optionsCount - 1))

        // 随机打乱选项，记录正确索引
        var allOptions = (wrongs + [correct]).shuffled()
        let correctIndex = allOptions.firstIndex(of: correct) ?? 0

        return QuizQuestion(
            type: pool.type,
            stem: pool.stem,
            options: allOptions,
            correctIndex: correctIndex,
            explanation: pool.explanation,
            jlptLevel: pool.jlptLevel
        )
    }

    // MARK: - 内部模板

    private struct QuestionTemplate {
        let type: QuizQuestionType
        let stem: String
        let correctAnswer: String
        let wrongAnswers: [String]
        let explanation: String
        let jlptLevel: String
    }

    // MARK: - 语法题库（N2-N3）

    private static let grammarPool: [QuestionTemplate] = [
        QuestionTemplate(
            type: .grammar,
            stem: "毎日日本語を勉強し（　）ならない。",
            correctAnswer: "なければ",
            wrongAnswers: ["ないと", "なくて", "ないは"],
            explanation: "「〜なければならない」表示「必须…」，N3 重点语法。动词ない形去掉「ない」+ なければならない。",
            jlptLevel: "N3"
        ),
        QuestionTemplate(
            type: .grammar,
            stem: "この本は一度読んで（　）ください。",
            correctAnswer: "みて",
            wrongAnswers: ["いて", "おいて", "しまって"],
            explanation: "「〜てみる」表示「试着做…」。読んでみてください = 请试着读一下。",
            jlptLevel: "N3"
        ),
        QuestionTemplate(
            type: .grammar,
            stem: "雨が降っている（　）、出かけた。",
            correctAnswer: "のに",
            wrongAnswers: ["ので", "から", "ても"],
            explanation: "「〜のに」表示「明明…却…」带有遗憾语气。整句：明明下着雨，却出门了。",
            jlptLevel: "N3"
        ),
        QuestionTemplate(
            type: .grammar,
            stem: "音楽を聞き（　）勉強する。",
            correctAnswer: "ながら",
            wrongAnswers: ["たり", "ても", "ながらも"],
            explanation: "「〜ながら」表示「一边…一边…」。动词ます形去掉ます + ながら。",
            jlptLevel: "N3"
        ),
        QuestionTemplate(
            type: .grammar,
            stem: "日本語が上手になる（　）、面白くなってきた。",
            correctAnswer: "につれて",
            wrongAnswers: ["にとって", "について", "に対して"],
            explanation: "「〜につれて」表示「随着…」。前项变化，后项也渐渐变化。",
            jlptLevel: "N3"
        ),
        QuestionTemplate(
            type: .grammar,
            stem: "彼は責任者（　）、みんなをまとめている。",
            correctAnswer: "として",
            wrongAnswers: ["にとって", "としても", "としては"],
            explanation: "「〜として」表示「作为…身份/资格」。彼作为负责人，带领大家。",
            jlptLevel: "N4"
        ),
        QuestionTemplate(
            type: .grammar,
            stem: "この問題は難し（　）すぎる。",
            correctAnswer: "く",
            wrongAnswers: ["い", "さ", "くて"],
            explanation: "「〜すぎる」表示「过于…」。形容词い→く + すぎる（難しすぎる）。",
            jlptLevel: "N4"
        ),
        QuestionTemplate(
            type: .grammar,
            stem: "約束は守る（　）だ。",
            correctAnswer: "べき",
            wrongAnswers: ["そう", "らしい", "ため"],
            explanation: "「〜べきだ」表示「应该…」。动词原形 + べきだ。約束は守るべきだ = 应该遵守约定。",
            jlptLevel: "N2"
        ),
        QuestionTemplate(
            type: .grammar,
            stem: "あの人は日本人に違い（　）。",
            correctAnswer: "ない",
            wrongAnswers: ["ある", "なった", "しない"],
            explanation: "「〜に違いない」表示「一定是…、肯定…」。非常肯定的推测。彼一定是日本人。",
            jlptLevel: "N2"
        ),
        QuestionTemplate(
            type: .grammar,
            stem: "今日は大事な日だから、遅れる（　）にはいかない。",
            correctAnswer: "わけ",
            wrongAnswers: ["はず", "もの", "こと"],
            explanation: "「〜わけにはいかない」表示「不能…（出于道义/规则）」。今天很重要，不能迟到。",
            jlptLevel: "N2"
        ),
        QuestionTemplate(
            type: .grammar,
            stem: "便利になる（　）で、問題も増えた。",
            correctAnswer: "一方",
            wrongAnswers: ["反面", "半分", "以上"],
            explanation: "「〜一方で」表示「一方面…另一方面…」。变得便利的同时，问题也增多。",
            jlptLevel: "N2"
        ),
        QuestionTemplate(
            type: .grammar,
            stem: "買った（　）、全然使っていない。",
            correctAnswer: "ものの",
            wrongAnswers: ["ものを", "ものか", "ものなら"],
            explanation: "「〜ものの」表示「虽然…但是…」。虽然买了，但完全没用。",
            jlptLevel: "N1"
        ),
        QuestionTemplate(
            type: .grammar,
            stem: "この説明は分かり（　）やすい。",
            correctAnswer: "やす",
            wrongAnswers: ["やすく", "やすけれ", "やすい"],
            explanation: "「〜やすい」表示「容易…」。动词ます形去掉ます + やすい。分かりやすい = 容易理解。",
            jlptLevel: "N4"
        ),
        QuestionTemplate(
            type: .grammar,
            stem: "明日は雨が降る（　）。",
            correctAnswer: "らしい",
            wrongAnswers: ["そうらしい", "みたいらしい", "ようらしい"],
            explanation: "「〜らしい」表示「好像…（根据传闻/推测）」。听说明天会下雨。",
            jlptLevel: "N4"
        )
    ]

    // MARK: - 词汇题库（N2-N3）

    private static let vocabularyPool: [QuestionTemplate] = [
        QuestionTemplate(
            type: .vocabulary,
            stem: "「努力」的正确读音是？",
            correctAnswer: "どりょく",
            wrongAnswers: ["ぬりょく", "どりき", "つとめ"],
            explanation: "「努力（どりょく）」= 努力。注意「努」读「ど」而非「ぬ」。",
            jlptLevel: "N3"
        ),
        QuestionTemplate(
            type: .vocabulary,
            stem: "「経験」的正确读音是？",
            correctAnswer: "けいけん",
            wrongAnswers: ["けいげん", "きょうけん", "けいかん"],
            explanation: "「経験（けいけん）」= 经验。注意「験」读「けん」。",
            jlptLevel: "N3"
        ),
        QuestionTemplate(
            type: .vocabulary,
            stem: "「大切」的正确读音是？",
            correctAnswer: "たいせつ",
            wrongAnswers: ["だいせつ", "おおぎり", "たいきる"],
            explanation: "「大切（たいせつ）」= 重要、珍贵。注意「大」读「たい」。",
            jlptLevel: "N3"
        ),
        QuestionTemplate(
            type: .vocabulary,
            stem: "「増加」的意思是？",
            correctAnswer: "增加",
            wrongAnswers: ["减少", "停止", "转移"],
            explanation: "「増加（ぞうか）」= 增加。反义词是「減少（げんしょう）」。",
            jlptLevel: "N2"
        ),
        QuestionTemplate(
            type: .vocabulary,
            stem: "「改善」的意思是？",
            correctAnswer: "改善、改进",
            wrongAnswers: ["破坏", "颠覆", "维持"],
            explanation: "「改善（かいぜん）」= 改善、改进。常用于生活、工作、制度等。",
            jlptLevel: "N2"
        ),
        QuestionTemplate(
            type: .vocabulary,
            stem: "「有能」的意思是？",
            correctAnswer: "有才能的",
            wrongAnswers: ["无能的", "有钱的", "有名的"],
            explanation: "「有能（ゆうのう）」= 有才能的、能干的。反义词「無能（むのう）」。",
            jlptLevel: "N2"
        ),
        QuestionTemplate(
            type: .vocabulary,
            stem: "「遠慮」的意思是？",
            correctAnswer: "客气、谦让",
            wrongAnswers: ["考虑", "远见", "远离"],
            explanation: "「遠慮（えんりょ）」= 客气、谦让。「遠慮なく」= 不客气地。",
            jlptLevel: "N2"
        ),
        QuestionTemplate(
            type: .vocabulary,
            stem: "「確認」的读音是？",
            correctAnswer: "かくにん",
            wrongAnswers: ["かくしん", "かくてい", "きゃくにん"],
            explanation: "「確認（かくにん）」= 确认。商务日语中非常常用。",
            jlptLevel: "N3"
        ),
        QuestionTemplate(
            type: .vocabulary,
            stem: "「豊か」的意思是？",
            correctAnswer: "丰富、富裕",
            wrongAnswers: ["贫穷", "肥胖", "丰收"],
            explanation: "「豊か（ゆたか）」= 丰富、富裕。「心が豊か」= 内心丰富。",
            jlptLevel: "N2"
        ),
        QuestionTemplate(
            type: .vocabulary,
            stem: "「提供」的读音是？",
            correctAnswer: "ていきょう",
            wrongAnswers: ["ていきゅう", "ていこう", "きょうてい"],
            explanation: "「提供（ていきょう）」= 提供。注意「供」读「きょう」。",
            jlptLevel: "N2"
        ),
        QuestionTemplate(
            type: .vocabulary,
            stem: "「案内」的意思是？",
            correctAnswer: "引导、向导",
            wrongAnswers: ["提案", "安静", "内容"],
            explanation: "「案内（あんない）」= 引导、向导。「案内します」= 我来带您。",
            jlptLevel: "N3"
        ),
        QuestionTemplate(
            type: .vocabulary,
            stem: "「準備」的读音是？",
            correctAnswer: "じゅんび",
            wrongAnswers: ["じゅんぴ", "しゅんび", "そなえ"],
            explanation: "「準備（じゅんび）」= 准备。注意「備」读「び」（浊音）。",
            jlptLevel: "N3"
        )
    ]
}
