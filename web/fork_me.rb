# https://github.com/blog/273-github-ribbons
class ForkMe < Erector::Widget
  def content
    rawtext <<-HTML
    <a href="http://github.com/erector/erector"><img style="position: absolute; top: 0; right: 0; border: 0;" src="https://a248.e.akamai.net/assets.github.com/img/30f550e0d38ceb6ef5b81500c64d970b7fb0f028/687474703a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f6f72616e67655f6666373630302e706e67" alt="Fork me on GitHub"></a>
    HTML
  end
end
