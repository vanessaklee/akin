defmodule DoubleTest do
  use ExUnit.Case

  import Akin.Metaphone.Double

  test "returns nil with empty argument" do
    assert parse("") == {"", ""}
  end

  test "returns nil with non-phonetic argument" do
    assert parse("123") == {"", ""}
  end

  test "return the expected phonetic responses - z" do
    assert parse("z") == {"s", "s"}
    assert parse("zz") == {"s", "s"}
  end

  test "return the expected phonetic responses - y" do
    assert parse("y") == {"a", "a"}
    assert parse("zy") == {"s", "s"}
    assert parse("zyz") == {"ss", "ss"}
    assert parse("zya") == {"s", "s"}
  end

  test "return the expected phonetic responses - x" do
    assert parse("x") == {"s", "s"}
    assert parse("zx") == {"sks", "sks"}
    assert parse("zxz") == {"skss", "skss"}
  end

  test "return the expected phonetic responses - w" do
    assert parse("w") == {"", ""}
    assert parse("zw") == {"s", "s"}
    assert parse("zwz") == {"ss", "sts"}
    assert parse("zwa") == {"s", "s"}
  end

  test "return the expected phonetic responses - v" do
    assert parse("v") == {"f", "f"}
    assert parse("zv") == {"sf", "sf"}
    assert parse("zvz") == {"sfs", "sfs"}
  end

  test "return the expected phonetic responses - u" do
    assert parse("u") == {"a", "a"}
    assert parse("zu") == {"s", "s"}
  end

  test "return the expected phonetic responses - t" do
    assert parse("t") == {"t", "t"}
    assert parse("ztiaz") == {"sxs", "sxs"}
    assert parse("ztioz") == {"sts", "sts"}
    assert parse("zthz") == {"s0s", "sts"}
    assert parse("ztchz") == {"sxs", "sxs"}
    assert parse("ztz") == {"sts", "sts"}
  end

  test "return the expected phonetic responses - s" do
    assert parse("s") == {"s", "s"}
    assert parse("zshz") == {"sxs", "sxs"}
    assert parse("zsioz") == {"sxs", "sss"}
    assert parse("zsiaz") == {"sxs", "sss"}
    assert parse("zs") == {"ss", "ss"}
    assert parse("zsz") == {"ss", "sx"}
  end

  test "return the expected phonetic responses - r" do
    assert parse("r") == {"r", "r"}
    assert parse("zr") == {"sr", "sr"}
    assert parse("zrz") == {"srs", "srs"}
  end

  test "return the expected phonetic responses - q" do
    assert parse("q") == {"k", "k"}
    assert parse("zq") == {"sk", "sk"}
    assert parse("zqz") == {"sks", "sks"}
  end

  test "return the expected phonetic responses - p" do
    assert parse("p") == {"p", "p"}
    assert parse("zp") == {"sp", "sp"}
    assert parse("zph") == {"sf", "sf"}
    assert parse("zpz") == {"sps", "sps"}
  end

  test "return the expected phonetic responses - o" do
    assert parse("o") == {"a", "a"}
    assert parse("zo") == {"s", "s"}
  end

  test "return the expected phonetic responses - n" do
    assert parse("n") == {"n", "n"}
    assert parse("zn") == {"sn", "sn"}
    assert parse("znz") == {"sns", "sns"}
  end

  test "return the expected phonetic responses -m" do
    assert parse("m") == {"m", "m"}
    assert parse("zm") == {"sm", "sm"}
    assert parse("zmz") == {"sms", "sms"}
  end

  test "return the expected phonetic responses - l" do
    assert parse("l") == {"l", "l"}
    assert parse("zl") == {"sl", "sl"}
    assert parse("zlz") == {"sls", "sls"}
  end

  test "return the expected phonetic responses - k" do
    assert parse("k") == {"k", "k"}
    assert parse("zk") == {"sk", "sk"}
    assert parse("zck") == {"sk", "sk"}
  end

  test "return the expected phonetic responses - j" do
    assert parse("j") == {"j", "a"}
    assert parse("zj") == {"sj", "s "}
    assert parse("zjz") == {"ss", "ss"}
  end

  test "return the expected phonetic responses - i" do
    assert parse("i") == {"a", "a"}
    assert parse("zi") == {"s", "s"}
  end

  test "return the expected phonetic responses - h" do
    assert parse("h") == {"h", "h"}
    assert parse("zh") == {"j", "j"}
    assert parse("zah") == {"s", "s"}
    assert parse("zchh") == {"sx", "sk"}
    assert parse("ha") == {"h", "h"}
  end

  test "return the expected phonetic responses - g" do
    assert parse("g") == {"k", "k"}
    assert parse("zg") == {"sk", "sk"}
    assert parse("zgh") == {"sk", "sk"}
    assert parse("zghz") == {"sks", "sks"}
    assert parse("zgha") == {"sk", "sk"}
    assert parse("zgn") == {"sn", "skn"}
    assert parse("zgns") == {"sns", "skns"}
    assert parse("zgned") == {"snt", "sknt"}
    assert parse("zgneds") == {"snts", "sknts"}
    assert parse("zgi") == {"sj", "sk"}
    assert parse("zgiz") == {"sjs", "sks"}
    assert parse("zge") == {"sj", "sk"}
    assert parse("zgez") == {"sjs", "sks"}
    assert parse("zgy") == {"sk", "sj"}
    assert parse("zgyz") == {"sks", "sjs"}
    assert parse("zgz") == {"sks", "sks"}
  end

  test "return the expected phonetic responses - f" do
    assert parse("f") == {"f", "f"}
    assert parse("zf") == {"sf", "sf"}
    assert parse("zfz") == {"sfs", "sfs"}
  end

  test "return the expected phonetic responses - e" do
    assert parse("e") == {"a", "a"}
    assert parse("ze") == {"s", "s"}
  end

  test "return the expected phonetic responses - d" do
    assert parse("d") == {"t", "t"}
    assert parse("fudge") == {"fj", "fj"}
    assert parse("dodgy") == {"tj", "tj"}
    assert parse("dodgi") == {"tj", "tj"}
    assert parse("zd") == {"st", "st"}
    assert parse("zdz") == {"sts", "sts"}
  end

  test "return the expected phonetic responses - c" do
    assert parse("c") == {"k", "k"}
    assert parse("zcia") == {"ss", "sx"}
    assert parse("zciaz") == {"sss", "sxs"}
    assert parse("zch") == {"sx", "sk"}
    assert parse("zchz") == {"sxs", "sks"}
    assert parse("zci") == {"ss", "ss"}
    assert parse("zciz") == {"sss", "sss"}
    assert parse("zce") == {"ss", "ss"}
    assert parse("zcez") == {"sss", "sss"}
    assert parse("zcy") == {"ss", "ss"}
    assert parse("zcyz") == {"sss", "sss"}
    assert parse("zsci") == {"ss", "ss"}
    assert parse("zsciz") == {"sss", "sss"}
    assert parse("zsce") == {"ss", "ss"}
    assert parse("zscez") == {"sss", "sss"}
    assert parse("zscy") == {"ss", "ss"}
    assert parse("zscyz") == {"sss", "sss"}
    assert parse("zsch") == {"sx", "sx"}
    assert parse("zc") == {"sk", "sk"}
    assert parse("zcz") == {"ss", "sx"}
  end

  test "return the expected phonetic responses - b" do
    assert parse("b") == {"p", "p"}
    assert parse("zb") == {"sp", "sp"}
    assert parse("zbz") == {"sps", "sps"}
    assert parse("zmb") == {"smp", "smp"}
  end

  test "return the expected phonetic responses - a" do
    assert parse("a") == {"a", "a"}
    assert parse("za") == {"s", "s"}
  end

  test "return the expected phonetic responses - misc" do
    assert parse("dumb") == {"tmp", "tmp"}
    assert parse("smith") == {"sm0", "xmt"}
    assert parse("school") == {"skl", "skl"}
    assert parse("merci") == {"mrs", "mrs"}
    assert parse("cool") == {"kl", "kl"}
    assert parse("aebersold") == {"aprslt", "aprslt"}
    assert parse("gnagy") == {"nk", "nj"}
    assert parse("knuth") == {"n0", "nt"}
    assert parse("pniewski") == {"nsk", "nfsk"}
    assert parse("wright") == {"rt", "rt"}
    assert parse("phone") == {"fn", "fn"}
    assert parse("aggregate") == {"akrkt", "akrkt"}
    assert parse("accuracy") == {"akrs", "akrs"}
    assert parse("encyclopedia") == {"ansklpt", "ansklpt"}
    assert parse("honorificabilitudinitatibus") == {"hnrfkplttnttps", "hnrfkplttnttps"}
    assert parse("antidisestablishmentarianism") == {"anttsstplxmntrnsm", "anttsstplxmntrnsm"}
  end
end
