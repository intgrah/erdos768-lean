import RequestProject.Defs

open Filter

namespace Erdos768

theorem erdos_768 :
    Tendsto
      (fun x : ℝ =>
        Real.log (x / (Acount x : ℝ)) / (Real.sqrt (Real.log x) * Real.log (Real.log x)))
      atTop (nhds c₀) := sorry

end Erdos768
