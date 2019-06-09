qui {
  /****************************************************************************************/
  /* label_election_vars : adds variable labels to election variables                     */
  /****************************************************************************************/
  cap label var mla_party "Party of MLA in this constituency"
  cap label var runnerup_party "Party of runner up in this constituency"
  cap label var coalition_party "Name of state coalition party with most seats"
  cap label var opposition_party "Name of state non-coalition party with most seats"
  cap label var local_coalition_party "Most successful coalition party in this constituency"
  cap label var local_opposition_party "Most successful non-coalition, non-independent party in this constituency"
  cap label var opposition "Dummy variable indicates opposition party is in 1st or 2nd place here"
  cap label var opp_leader_win_count "Number of seats of the state opposition party"
  cap label var coal_leader_win_count "Number of seats of the state coalition leader party"
  cap label var coal_win_count "Number of seats held by all state coalition parties"
  cap label var coal_share_ex_post "Share of seats held by ex-post coalition"
  cap label var coal_share_synth "Share of seats held by predicted coalition"

  cap label var coal_share_synth "Share of seats held by predicted coalition"
  cap label var aligned "Aligned"
  cap label var margin "Margin of Victory"
  cap label var m_a "Aligned * Margin"

  cap label var baseline "Baseline Log Employment"
  cap label var ln_pop91 "Baseline Log Population"
  cap label var urbanization "Urbanization Rate"
  cap label var pc91_vd_power_supl "Share of Villages with Power"
  cap label var irr_share91 "Share of Arable Land Irrigated"
  cap label var p_sch_r91 "Primary Schools per Village"

  cap label var margin1 "predicted margin based on ex ante information"
  cap label var margin2 "predicted margin based on ex ante information"
  cap label var margin3 "predicted margin based on ex ante information"
  cap label var margin4 "predicted margin based on ex ante information"
  cap label var margin5 "margin of bigger party at state level, where neither 1st nor 2nd place aligned with state coalition"
  cap label var margin6 "incumbent minus top non-incumbent"
  cap label var margin7 "state-level incumbent party minus highest non-incumbent"
  cap label var margin8 "top candidate minus second place candidate"
}


