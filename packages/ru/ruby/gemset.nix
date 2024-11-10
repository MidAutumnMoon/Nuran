{
  amazing_print = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15vklc53pgf2zr1rvncy4yz7ikm63k5ghfa2hlf425fwm8yyj0wr";
      type = "gem";
    };
    version = "1.6.0";
  };
  async = {
    dependencies = ["console" "fiber-annotation" "io-event"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lbpww3r1mk1dhs4f8gc3iqg9prhpnqzi51fmni2ilnsma2zr2vz";
      type = "gem";
    };
    version = "2.19.0";
  };
  bigdecimal = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1gi7zqgmqwi5lizggs1jhc3zlwaqayy9rx2ah80sxy24bbnng558";
      type = "gem";
    };
    version = "3.1.8";
  };
  console = {
    dependencies = ["fiber-annotation" "fiber-local" "json"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "11cp6jvwldy3qgaxhppwsnqq26ciq66v59jm33miw2dhby5bms34";
      type = "gem";
    };
    version = "1.29.0";
  };
  fiber-annotation = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00vcmynyvhny8n4p799rrhcx0m033hivy0s1gn30ix8rs7qsvgvs";
      type = "gem";
    };
    version = "0.2.0";
  };
  fiber-local = {
    dependencies = ["fiber-storage"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01lz929qf3xa90vra1ai1kh059kf2c8xarfy6xbv1f8g457zk1f8";
      type = "gem";
    };
    version = "1.1.0";
  };
  fiber-storage = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0zxblmxwdpj3587wji5325y53gjdcmzxzm6126dyg58b3qzk42mq";
      type = "gem";
    };
    version = "1.0.0";
  };
  io-console = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "08d2lx42pa8jjav0lcjbzfzmw61b8imxr9041pva8xzqabrczp7h";
      type = "gem";
    };
    version = "0.7.2";
  };
  io-event = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1cicd7dpnksbj7pjqzbz993p36qja0gw0wlgi49m7z11agg91fp2";
      type = "gem";
    };
    version = "1.7.3";
  };
  irb = {
    dependencies = ["rdoc" "reline"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1y40dv3caswr81dlsyln6vnmmpzf5jcal2rqjbsglvnkb0xh0xar";
      type = "gem";
    };
    version = "1.14.1";
  };
  json = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ap2ks9yfzr9d0ig50wanws36lpkh3if5favl5pplv7gqaj8qkj0";
      type = "gem";
    };
    version = "2.8.1";
  };
  psych = {
    dependencies = ["stringio"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wq567f615x1ilgaqlh4yzf322f96rgn45xw4nm4vwfaddszw0v6";
      type = "gem";
    };
    version = "5.2.0";
  };
  rdoc = {
    dependencies = ["psych"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ygk2zk0ky3d88v3ll7qh6xqvbvw5jin0hqdi1xkv1dhaw7myzdi";
      type = "gem";
    };
    version = "6.7.0";
  };
  reinbow = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0sh36blmaa6l0hhwxsyh4dfbydycy8q4ga9f43w1sm2m9w8zlsqj";
      type = "gem";
    };
    version = "2.0.0";
  };
  reline = {
    dependencies = ["io-console"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rfblw8mnk8bwzcpqpan9vpblw4b4pxgdxw206kszjnrpx6mz3c6";
      type = "gem";
    };
    version = "0.5.11";
  };
  stringio = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cd1kdrf62p2ya3ia4rz49d5012bqinvqjmcgkakknswz0l1hkr0";
      type = "gem";
    };
    version = "3.1.2";
  };
  tomlib = {
    dependencies = ["bigdecimal"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0n0x6h3a5sd7dclrsy8fnbv9m2nkl8raq9qkg5pr2cd02axm77kf";
      type = "gem";
    };
    version = "0.7.2";
  };
}
