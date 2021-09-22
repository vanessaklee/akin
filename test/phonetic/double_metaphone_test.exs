defmodule DoubleMetaphoneTest do
  use ExUnit.Case

  import Akin.Phonetic.DoubleMetaphone

  test "returns nil with empty argument" do
    assert parse("") == {"", ""}
  end

  test "returns nil with non-phonetic argument" do
    assert parse("123") == {"", ""}
  end

  test "return the expected phonetic responses" do
    # z
    assert parse("z") == {"s", ""}
    assert parse("zz") == {"s", ""}

    # y
    assert parse("y") == {"a", ""}
    assert parse("zy") == {"s", ""}
    assert parse("zyz") == {"ss", ""}
    assert parse("zya") == {"s", ""}

    # x
    assert parse("x") == {"s", ""}
    assert parse("zx") == {"sks", ""}
    assert parse("zxz") == {"skss", ""}

    # w
    assert parse("w") == {"", ""}
    assert parse("zw") == {"s", ""}
    assert parse("zwz") == {"ss", "sts"}
    assert parse("zwa") == {"s", ""}

    # v
    assert parse("v") == {"f", ""}
    assert parse("zv") == {"sf", ""}
    assert parse("zvz") == {"sfs", ""}

    # u
    assert parse("u") == {"a", ""}
    assert parse("zu") == {"s", ""}

    # t
    assert parse("t") == {"t", ""}
    assert parse("ztiaz") == {"sxs", ""}
    assert parse("ztioz") == {"sts", ""}
    assert parse("zthz") == {"s0s", "sts"}
    assert parse("ztchz") == {"sxs", ""}
    assert parse("ztz") == {"sts", ""}

    # s
    assert parse("s") == {"s", ""}
    assert parse("zshz") == {"sxs", ""}
    assert parse("zsioz") == {"sxs", "sss"}
    assert parse("zsiaz") == {"sxs", "sss"}
    assert parse("zs") == {"ss", ""}
    assert parse("zsz") == {"ss", "sx"}

    # r
    assert parse("r") == {"r", ""}
    assert parse("zr") == {"sr", ""}
    assert parse("zrz") == {"srs", ""}

    # q
    assert parse("q") == {"k", ""}
    assert parse("zq") == {"sk", ""}
    assert parse("zqz") == {"sks", ""}

    # p
    assert parse("p") == {"p", ""}
    assert parse("zp") == {"sp", ""}
    assert parse("zph") == {"sf", ""}
    assert parse("zpz") == {"sps", ""}

    # o
    assert parse("o") == {"a", ""}
    assert parse("zo") == {"s", ""}

    # n
    assert parse("n") == {"n", ""}
    assert parse("zn") == {"sn", ""}
    assert parse("znz") == {"sns", ""}

    # m
    assert parse("m") == {"m", ""}
    assert parse("zm") == {"sm", ""}
    assert parse("zmz") == {"sms", ""}

    # l
    assert parse("l") == {"l", ""}
    assert parse("zl") == {"sl", ""}
    assert parse("zlz") == {"sls", ""}

    # k
    assert parse("k") == {"k", ""}
    assert parse("zk") == {"sk", ""}
    assert parse("zck") == {"sk", ""}

    # j
    assert parse("j") == {"j", "a"}
    assert parse("zj") == {"sj", "s "}
    assert parse("zjz") == {"ss", ""}

    # i
    assert parse("i") == {"a", ""}
    assert parse("zi") == {"s", ""}

    # h
    # php wrongly says nil
    assert parse("h") == {"h", ""}
    # php wrongly says s
    assert parse("zh") == {"j", ""}
    assert parse("zah") == {"s", ""}
    assert parse("zchh") == {"sx", "sk"}
    assert parse("ha") == {"h", ""}

    # g
    assert parse("g") == {"k", ""}
    assert parse("zg") == {"sk", ""}
    # php wrongly says sf
    assert parse("zgh") == {"sk", ""}
    # php wrongly says sfs
    assert parse("zghz") == {"sks", ""}
    # php wrongly says sf
    assert parse("zgha") == {"sk", ""}
    # others wrongly say skh
    assert parse("zgn") == {"sn", "skn"}
    assert parse("zgns") == {"sns", "skns"}
    # others wrongly says sknt
    assert parse("zgned") == {"snt", "sknt"}
    # php wrongly says snts
    assert parse("zgneds") == {"snts", "sknts"}
    assert parse("zgi") == {"sj", "sk"}
    assert parse("zgiz") == {"sjs", "sks"}
    assert parse("zge") == {"sj", "sk"}
    assert parse("zgez") == {"sjs", "sks"}
    assert parse("zgy") == {"sk", "sj"}
    assert parse("zgyz") == {"sks", "sjs"}
    assert parse("zgz") == {"sks", ""}

    # f
    assert parse("f") == {"f", ""}
    assert parse("zf") == {"sf", ""}
    assert parse("zfz") == {"sfs", ""}

    # e
    assert parse("e") == {"a", ""}
    assert parse("ze") == {"s", ""}

    # d
    assert parse("d") == {"t", ""}
    # php wrongly says fj
    assert parse("fudge") == {"fj", ""}
    # php wrongly says tj
    assert parse("dodgy") == {"tj", ""}
    # others wrongly say tjjy
    # php wrongly says tj
    assert parse("dodgi") == {"tj", ""}
    assert parse("zd") == {"st", ""}
    assert parse("zdz") == {"sts", ""}

    # c
    assert parse("c") == {"k", ""}
    assert parse("zcia") == {"ss", "sx"}
    assert parse("zciaz") == {"sss", "sxs"}
    assert parse("zch") == {"sx", "sk"}
    assert parse("zchz") == {"sxs", "sks"}
    assert parse("zci") == {"ss", ""}
    assert parse("zciz") == {"sss", ""}
    assert parse("zce") == {"ss", ""}
    assert parse("zcez") == {"sss", ""}
    assert parse("zcy") == {"ss", ""}
    assert parse("zcyz") == {"sss", ""}
    assert parse("zsci") == {"ss", ""}
    assert parse("zsciz") == {"sss", ""}
    assert parse("zsce") == {"ss", ""}
    assert parse("zscez") == {"sss", ""}
    assert parse("zscy") == {"ss", ""}
    assert parse("zscyz") == {"sss", ""}
    # php wrongly says ssx
    assert parse("zsch") == {"sx", ""}
    assert parse("zc") == {"sk", ""}
    assert parse("zcz") == {"ss", "sx"}

    # b
    assert parse("b") == {"p", ""}
    assert parse("zb") == {"sp", ""}
    assert parse("zbz") == {"sps", ""}
    assert parse("zmb") == {"smp", ""}

    # a
    assert parse("a") == {"a", ""}
    assert parse("za") == {"s", ""}

    # Miscellaneous.
    assert parse("dumb") == {"tmp", ""}
    assert parse("smith") == {"sm0", "xmt"}
    # php wrongly says sxl
    assert parse("school") == {"skl", ""}
    assert parse("merci") == {"mrs", ""}
    assert parse("cool") == {"kl", ""}
    assert parse("aebersold") == {"aprslt", ""}
    assert parse("gnagy") == {"nk", "nj"}
    assert parse("knuth") == {"n0", "nt"}
    assert parse("pniewski") == {"nsk", "nfsk"}
    # php wrongly says rft
    assert parse("wright") == {"rt", ""}
    assert parse("phone") == {"fn", ""}
    assert parse("aggregate") == {"akrkt", ""}
    assert parse("accuracy") == {"akrs", ""}
    assert parse("encyclopedia") == {"ansklpt", ""}
    assert parse("honorificabilitudinitatibus") == {"hnrfkplttnttps", ""}
    assert parse("antidisestablishmentarianism") == {"anttsstplxmntrnsm", ""}
  end
end
