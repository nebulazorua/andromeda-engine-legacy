package;

class ScoreUtils
{
	public static var gradeArray:Array<String> = ["☆☆☆☆","☆☆☆","☆☆","☆","S+","S","S-","A+","A","A-","B+","B","B-","C+","C","C-","D"];

	public static function GetAccuracyConditions(): Array<Float>{
		return [
      1.0, // Quad star
      .99, // Trip star
      .98, // Doub star
      .96, // Single star
      .94, // S+
      .92, // S
      .89, // S-
      .86, // A+
      .83, // A
      .8, // A-
      .76, // B+
      .72, // B
      .68, // B-
      .64, // C+
      .6, // C
      .55, // C-
    ];
	}
  public static function AccuracyToGrade(accuracy:Float):String {
    var grade = gradeArray[gradeArray.length-1];
    var accuracyConditions:Array<Float>=GetAccuracyConditions();
    for(i in 0...accuracyConditions.length){
      if(accuracy > accuracyConditions[i]){
        grade = gradeArray[i];
        break;
      }
    }

    return grade;
  }
}
