using System;

// Question 3 - Part 3: Code Analysis
// السؤال 3 - الجزء الثالث: تحليل الكود

class Q3_Solution
{
    static void Main()
    {
        Console.WriteLine("Question 3 - Part 3 Output:");
        Console.WriteLine("السؤال 3 - الجزء الثالث - الإخراج:\n");
        
        // The exact code from the question
        // الكود بالضبط من السؤال
        for (int i = 0; i < 10; i++)
        {
            if (i == 2 || i == 6)  { continue; }
            if (i == 4 && i == 8)  { break;    }
            Console.Write(i);
        }
        
        Console.WriteLine("\n\nExplanation / الشرح:");
        Console.WriteLine("- Numbers 2 and 6 are skipped (continue)");
        Console.WriteLine("- الأرقام 2 و 6 يتم تخطيها (continue)");
        Console.WriteLine("- The break never executes (i cannot be 4 AND 8 at same time)");
        Console.WriteLine("- جملة break لن تنفذ أبداً (i لا يمكن أن يساوي 4 و 8 في نفس الوقت)");
        Console.WriteLine("\nAnswer: 01345789");
        Console.WriteLine("الإجابة: 01345789");
        
        Console.ReadKey();
    }
}
