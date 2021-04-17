package;

class ScoreUtils
{
	public static var gradeArray:Array<String> = ["☆☆☆☆","☆☆☆","☆☆","☆","S+","S","S-","A+","A","A-","B+","B","B-","C+","C","C-","D"];

  public static function AccuracyToGrade(accuracy:Float){
    var grade = "N";
    var accuracyConditions:Array<Bool>=[
      accuracy>=1, // Quad star
      accuracy>=.99, // Trip star
      accuracy>=.98, // Doub star
      accuracy>=.96, // Single star
      accuracy>=.94, // S+
      accuracy>=.92, // S
      accuracy>=.89, // S-
      accuracy>=.86, // A+
      accuracy>=.83, // A
      accuracy>=.8, // A-
      accuracy>=.76, // B+
      accuracy>=.72, // B
      accuracy>=.68, // B-
      accuracy>=.64, // C+
      accuracy>=.6, // C
      accuracy>=.55, // C-
      accuracy<.55 // D
    ];
    for(i in 0...accuracyConditions.length){
      var achieved = accuracyConditions[i];
      if(achieved){
        grade = gradeArray[i];
        break;
      }
    }

    return grade;
  }
}
