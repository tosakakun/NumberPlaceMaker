# Number Place Maker

Number Place Maker is a library for generating random Number Place Puzzle.

## Requirement

- iOS 14.0+
- macOS 11.0+

## Installation

### Swift Package Manager

1. In Xcode, select File > Add Packages....
1. Spacify the repository https://github.com/tosakakun/NumberPlaceMaker.git
1. Spacify options and then click Add Package.

## Usage

Create an instance of NumberPlaceMaker and call the makeNumberPlace(holes:) method with the required number of holes. It may not be possible to create Number Place. Use NumberPlaceSolver to solve Number Place if needed. 

```Swift
import NumberPlaceMaker

// To create Number Place
let maker = NumberPlaceMaker()
    
do {
        
    let numberPlace = try maker.makeNumberPlace(holes: 51)
    print("Creation Success")
    print("Number Place")
    print(numberPlace.punchedBoard)
    print("Answer")
    print(numberPlace.answerBoad)
        
    print("Solve the Number Place to use NumberPlaceSolver")
    let solver = NumberPlaceSolver()
    
    // To solve Number Place
    if let ans = solver.solve(board: numberPlace.punchedBoard) {
            
        print(ans)
            
        print("same answer? \(ans == numberPlace.answerBoad)")
            
            
    } else {
        print("can not solve")
    }

} catch let error as NPError {
    print(error.localizedDescription)
} catch {
    print(error.localizedDescription)
}
```

## Process Overview

To create Number Place

1. Prepare a board fulfilled numbers from 1 to 9 according to the rules of Number Place.
1. Create the required number of holes on the board.
1. Check to see if there is a unique solution.

This library attempts to create Number Place in a straightforward manner and may not be able to create it. Adjusting some parameters for the number of attempts in the NumberPlaceMaker initializer may improve this.

## License

This library is released under the MIT License.

## 雑記
数年前にとあるきっかけで作成したナンプレ生成処理を少し整理して、パッケージとして公開しました。作成当時の流れもあり、素直に愚直にナンプレを生成している（答えを準備し、そこにランダムな穴をあけている）ため、穴の数が多くなると生成できない可能性も高くなります。乱数を利用して生成していますが、実際どれだけランダムな問題が生成されているのか？異なる解が存在しないかのチェックは、有限回数（デフォルトでは5回）解くことでチェックしていますが、それで十分なのかも気になるところです。

数学的には、最小ヒント数が17個（穴が64個）であることが証明されているようですが、このパッケージのロジックでは、おそらく生成できないでしょう（あるいは、生成する（見つける）のに非常に時間がかかる？）。また、難しい問題を生成するには、穴の数をいくつにするか？穴の開け方をどうするのか？などなど興味深い話題が、いろいろありそうです。
