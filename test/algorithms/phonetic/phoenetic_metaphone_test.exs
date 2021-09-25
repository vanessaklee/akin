defmodule PhoenticMetaphoneTest do
  use ExUnit.Case
  import Akin.Metaphone.Metaphone, only: [compute: 1]
  alias Akin.Primed

  test "returns nil with empty argument" do
    assert compute(%Primed{string: ""}) == nil
  end

  test "returns nil with non-phonetic argument" do
    assert compute(%Primed{string: "123"}) == nil
  end

  test "return the expected phonetic responses" do
    # z
    assert compute(%Primed{string: "z"}) == "s"
    assert compute(%Primed{string: "zz"}) == "s"

    # y
    assert compute(%Primed{string: "y"}) == nil
    assert compute(%Primed{string: "zy"}) == "s"
    assert compute(%Primed{string: "zyz"}) == "ss"
    assert compute(%Primed{string: "zya"}) == "sy"

    # x
    assert compute(%Primed{string: "x"}) == "s"
    assert compute(%Primed{string: "zx"}) == "sks"
    assert compute(%Primed{string: "zxz"}) == "skss"

    # w
    assert compute(%Primed{string: "w"}) == nil
    assert compute(%Primed{string: "zw"}) == "s"
    assert compute(%Primed{string: "zwz"}) == "ss"
    assert compute(%Primed{string: "zwa"}) == "sw"

    # v
    assert compute(%Primed{string: "v"}) == "f"
    assert compute(%Primed{string: "zv"}) == "sf"
    assert compute(%Primed{string: "zvz"}) == "sfs"

    # u
    assert compute(%Primed{string: "u"}) == "u"
    assert compute(%Primed{string: "zu"}) == "s"

    # t
    assert compute(%Primed{string: "t"}) == "t"
    assert compute(%Primed{string: "ztiaz"}) == "sxs"
    assert compute(%Primed{string: "ztioz"}) == "sxs"
    assert compute(%Primed{string: "zthz"}) == "s0s"
    assert compute(%Primed{string: "ztchz"}) == "sxs"
    assert compute(%Primed{string: "ztz"}) == "sts"

    # s
    assert compute(%Primed{string: "s"}) == "s"
    assert compute(%Primed{string: "zshz"}) == "sxs"
    assert compute(%Primed{string: "zsioz"}) == "sxs"
    assert compute(%Primed{string: "zsiaz"}) == "sxs"
    assert compute(%Primed{string: "zs"}) == "ss"
    assert compute(%Primed{string: "zsz"}) == "sss"

    # r
    assert compute(%Primed{string: "r"}) == "r"
    assert compute(%Primed{string: "zr"}) == "sr"
    assert compute(%Primed{string: "zrz"}) == "srs"

    # q
    assert compute(%Primed{string: "q"}) == "k"
    assert compute(%Primed{string: "zq"}) == "sk"
    assert compute(%Primed{string: "zqz"}) == "sks"

    # p
    assert compute(%Primed{string: "p"}) == "p"
    assert compute(%Primed{string: "zp"}) == "sp"
    assert compute(%Primed{string: "zph"}) == "sf"
    assert compute(%Primed{string: "zpz"}) == "sps"

    # o
    assert compute(%Primed{string: "o"}) == "o"
    assert compute(%Primed{string: "zo"}) == "s"

    # n
    assert compute(%Primed{string: "n"}) == "n"
    assert compute(%Primed{string: "zn"}) == "sn"
    assert compute(%Primed{string: "znz"}) == "sns"

    # m
    assert compute(%Primed{string: "m"}) == "m"
    assert compute(%Primed{string: "zm"}) == "sm"
    assert compute(%Primed{string: "zmz"}) == "sms"

    # l
    assert compute(%Primed{string: "l"}) == "l"
    assert compute(%Primed{string: "zl"}) == "sl"
    assert compute(%Primed{string: "zlz"}) == "sls"

    # k
    assert compute(%Primed{string: "k"}) == "k"
    assert compute(%Primed{string: "zk"}) == "sk"
    assert compute(%Primed{string: "zck"}) == "sk"

    # j
    assert compute(%Primed{string: "j"}) == "j"
    assert compute(%Primed{string: "zj"}) == "sj"
    assert compute(%Primed{string: "zjz"}) == "sjs"

    # i
    assert compute(%Primed{string: "i"}) == "i"
    assert compute(%Primed{string: "zi"}) == "s"

    # h
    # php wrongly says nil
    assert compute(%Primed{string: "h"}) == "h"
    # php wrongly says s
    assert compute(%Primed{string: "zh"}) == "sh"
    assert compute(%Primed{string: "zah"}) == "s"
    assert compute(%Primed{string: "zchh"}) == "sx"
    assert compute(%Primed{string: "ha"}) == "h"

    # g
    assert compute(%Primed{string: "g"}) == "k"
    assert compute(%Primed{string: "zg"}) == "sk"
    # php wrongly says sf
    assert compute(%Primed{string: "zgh"}) == "skh"
    # php wrongly says sfs
    assert compute(%Primed{string: "zghz"}) == "shs"
    # php wrongly says sf
    assert compute(%Primed{string: "zgha"}) == "sh"
    # others wrongly say skh
    assert compute(%Primed{string: "zgn"}) == "sn"
    assert compute(%Primed{string: "zgns"}) == "skns"
    # others wrongly says sknt
    assert compute(%Primed{string: "zgned"}) == "snt"
    # php wrongly says snts
    assert compute(%Primed{string: "zgneds"}) == "sknts"
    assert compute(%Primed{string: "zgi"}) == "sj"
    assert compute(%Primed{string: "zgiz"}) == "sjs"
    assert compute(%Primed{string: "zge"}) == "sj"
    assert compute(%Primed{string: "zgez"}) == "sjs"
    assert compute(%Primed{string: "zgy"}) == "sj"
    assert compute(%Primed{string: "zgyz"}) == "sjs"
    assert compute(%Primed{string: "zgz"}) == "sks"

    # f
    assert compute(%Primed{string: "f"}) == "f"
    assert compute(%Primed{string: "zf"}) == "sf"
    assert compute(%Primed{string: "zfz"}) == "sfs"

    # e
    assert compute(%Primed{string: "e"}) == "e"
    assert compute(%Primed{string: "ze"}) == "s"

    # d
    assert compute(%Primed{string: "d"}) == "t"
    # php wrongly says fj
    assert compute(%Primed{string: "fudge"}) == "fjj"
    # php wrongly says tj
    assert compute(%Primed{string: "dodgy"}) == "tjj"
    # others wrongly say tjjy
    # php wrongly says tj
    assert compute(%Primed{string: "dodgi"}) == "tjj"
    assert compute(%Primed{string: "zd"}) == "st"
    assert compute(%Primed{string: "zdz"}) == "sts"

    # c
    assert compute(%Primed{string: "c"}) == "k"
    assert compute(%Primed{string: "zcia"}) == "sx"
    assert compute(%Primed{string: "zciaz"}) == "sxs"
    assert compute(%Primed{string: "zch"}) == "sx"
    assert compute(%Primed{string: "zchz"}) == "sxs"
    assert compute(%Primed{string: "zci"}) == "ss"
    assert compute(%Primed{string: "zciz"}) == "sss"
    assert compute(%Primed{string: "zce"}) == "ss"
    assert compute(%Primed{string: "zcez"}) == "sss"
    assert compute(%Primed{string: "zcy"}) == "ss"
    assert compute(%Primed{string: "zcyz"}) == "sss"
    assert compute(%Primed{string: "zsci"}) == "ss"
    assert compute(%Primed{string: "zsciz"}) == "sss"
    assert compute(%Primed{string: "zsce"}) == "ss"
    assert compute(%Primed{string: "zscez"}) == "sss"
    assert compute(%Primed{string: "zscy"}) == "ss"
    assert compute(%Primed{string: "zscyz"}) == "sss"
    # php wrongly says ssx
    assert compute(%Primed{string: "zsch"}) == "sskh"
    assert compute(%Primed{string: "zc"}) == "sk"
    assert compute(%Primed{string: "zcz"}) == "sks"

    # b
    assert compute(%Primed{string: "b"}) == "b"
    assert compute(%Primed{string: "zb"}) == "sb"
    assert compute(%Primed{string: "zbz"}) == "sbs"
    assert compute(%Primed{string: "zmb"}) == "sm"

    # a
    assert compute(%Primed{string: "a"}) == "a"
    assert compute(%Primed{string: "za"}) == "s"

    # Miscellaneous.
    assert compute(%Primed{string: "dumb"}) == "tm"
    assert compute(%Primed{string: "smith"}) == "sm0"
    # php wrongly says sxl
    assert compute(%Primed{string: "school"}) == "skhl"
    assert compute(%Primed{string: "merci"}) == "mrs"
    assert compute(%Primed{string: "cool"}) == "kl"
    assert compute(%Primed{string: "aebersold"}) == "ebrslt"
    assert compute(%Primed{string: "gnagy"}) == "nj"
    assert compute(%Primed{string: "knuth"}) == "n0"
    assert compute(%Primed{string: "pniewski"}) == "nsk"
    # php wrongly says rft
    assert compute(%Primed{string: "wright"}) == "rht"
    assert compute(%Primed{string: "phone"}) == "fn"
    assert compute(%Primed{string: "aggregate"}) == "akrkt"
    assert compute(%Primed{string: "accuracy"}) == "akkrs"
    assert compute(%Primed{string: "encyclopedia"}) == "ensklpt"
    assert compute(%Primed{string: "honorificabilitudinitatibus"}) == "hnrfkblttnttbs"
    assert compute(%Primed{string: "antidisestablishmentarianism"}) == "anttsstblxmntrnsm"
  end
end
