#set document(
  title: [Lecture 6 - Elliptic Curves & Pairings],
  author: "Gidon Rosalki",
  date: auto,
)
#set heading(numbering: "1.")
#set text(font: "New Computer Modern")
#set page(margin: (
  bottom: 0.5cm,
  right: 1.5cm,
  left: 1.5cm,
  top: 1.5cm,
))
#set list(indent: 10pt)
#set enum(indent: 10pt)

#show title: set align(center)
#show link: set text(rgb("005eff"))
#show link: underline
#show math.equation.where(block: true): set block(breakable: true)
#title()
#align(center)[
  Gidon Rosalki \
  2026-06-10
]

#let colourmaths(x, color) = text(fill: color)[$#x$]

#figure()[Notice: If you find any mistakes, please open an issue in #link("https://github.com/robomarvin1501/notes_crypto")[the github repository]]

= Introduction
Last semester, we discussed all manner of parts of asymmetric encryption, and always began with "Let $GG$ be a prime
order group", and from here continued onto assumptions such as DLOG, DDH, CDH, and so on. However, we never discussed
how we made these groups.

If we consider the group $(ZZ_p, +)$, we will note that these assumptions are not true for this group. If we instead
consider the group $(ZZ^*_p, times)$, then it would appear that these assumptions hold true over this group. This group
has $p - 1$ elements, which is an even amount. The complexity of the assumptions is dependent on the smallest subset of
the group, for which they hold true. Since the size of our group is even, we can relatively trivially break it into
smaller groups, and then it is very easy to solve these problems on top of these smaller groups. \
Instead of using this group, what we do is we take a subgroup of $(ZZ^*_p, times)$, of prime order, and work on top of that.
So, we will pick $p$ such that it is a safe prime, where $p = 2q + 1$. 
 
Our security parameter for DLOG is now $2 ^ (O(root(3, log p)))$. So, if we want a security parameter of 128 bits, then
we need it to hold that every value in our group will have about 3072 bits, since we have required $log p = 3072$.

This is quite a lot, so performing these computations is now very expensive. To resolve this, we begin considering
elliptic curves.

= Elliptic Curves
_Definition_: Pythagorean pairs are pairs of numbers where $x^2 + y^2 = 1$.

_Definition_: Fermat triples are triples of numbers where $x^3 + y^3 = z^3$. \
We will note that there are no such triples in $ZZ$, nor for any power greater than 2.

_Definition_: Diophantine pairs are pairs where $y^2 = x^3 + A x + B$

Diophantine pairs define elliptic curves. Currently, we do not know of any trivial method to break this type of
encryption. Currently, the best known method costs $O (2 ^ ((log p) / 2)$. So, if you want 128 bit security, then you
only need $log p = 256$, which is much more efficient than the traditional method. As a result, this is the method that
is used, but which group should we use? We have standardised on a few specific elliptic curves:
- secp256r1: 
  $
    p & = 2 ^ (256) - 2 ^ (224) + 2 ^ (192) + 2 ^ (96) - 1 \
    y^2 & = x ^ (3) - 3x + b : b = "magic"
  $
- secp256r1:
  $
    p & = 2 ^ (255) - 19
    y^2 & = x ^ (3) + 486662x^2 + x
  $

These appeared because some people chose them, and they appear good. What is particularly screwy is that there are good
$b$'s, and bad $b$'s, and the ones that we use are simply ones that were published by the NSA as "probably good" at some
point. Are they secretly an NSA backdoor into modern cryptography? Maybe.

#pagebreak()
= Pairings
A pairing is 
$
  e : GG times GG -> GG_T
$
such that it enables
+ Bilinearity : $e (g ^ (a), g ^ (b)) = e (g, g) ^ (a b)$
+ Non-Degeneracy : If $g$ generates $GG ==> e (g, g)$ generates $GG$
+ Efficiency : $e$ may be computed in polynomial time

So, why is this interesting? It potentially helps us break DDH (1993). If we can convert 2 groups to another group, which is
easier to break, then we can use the same ideas to break DDH. That is to say, DDH is that it is hard given $g ^
(a), g ^ (b)$ to compute $g ^ (a b)$. Since this concept directly seems to imply we can use it to break DDH, we can
either be exceedingly careful with our groups, or just not assume DDH in the original groups.

== Joux 2000 
Recall Diffie Hellman from the 70s, Alice selects $a$, Bob $b$, they send each other $g ^ (x) : x in {a,
b}$, and then may compute the entire key $g ^ (a b)$ by raising what they received to the power of their own number. 

How do we do this for 3 people, Alice, Bob, and Claire? Each will do the standard exchange with each other. Let us
consider Claire. Claire finishes the exchanges with $g ^ (a), g ^ (b), c$. She may now compute $e (g, g) ^ (a b)$, and
raise that to $c$, resulting in the shared key $e (g, g) ^ (a b c)$. 

This is DBDH: Decisional Bilinear Diffie Hellman, where we say that 
$
  (g ^ (a), g ^ (b), g ^ (c), e(g, g) ^ (a b c)) approx (g ^ (a), g ^ (b), g ^ (c), e(g, g) ^ (r))
$

== BLS 01
Boneh - Lynn - Shacham signatures. Let us briefly consider some other signatures.

#figure(
  caption: "Signatures",
)[
  #table(
    columns: (auto, auto, auto, auto, auto, auto),
    align: horizon,
    table.header([Scheme], [Group], [Security], [Group], [Size of signature], [bits]),
    "RSA", $ZZ^*_n$, $2 ^ (root(3, log n))$, $approx 3000$, "One group element", $approx 3000$,
    "ECDSA", "Elliptic curve", $sqrt(p)$, $256$, "2 group elements", $512$,
    "Schnorr", "Elliptic curve", $sqrt(p)$, $256$, "1 group element, + hash", $384$,
    "BLS", "Elliptic curve", $sqrt(p)$, $256$, "1 group element", $256$,
  )
]

#let sk = $s k$
#let vk = $v k$
How do we sign? We need:
- KeyGen: $sk = a, vk = (g ^ (a), g)$
- Sign(a, m): $sigma = H (m) ^ (a)$ for a hash function $H : {0, 1} ^ (n) -} GG$
- $"Verify"(g ^ (a), m, sigma)$: $e(H(m), g ^ (a)) == e(sigma, g)$ which should both return $e(g, g) ^ (a H(m))$
*Correctness*:
$
  e(sigma, g) = e(H(m) ^ (a), g) = e(g ^ (z a), g) = e(g, g) ^ (z a) \
  e(H(m), g ^ (a)) = e(g ^ (z), g ^ (a)) = e(g, g) ^ (z a) \
$
Assuming CDH in $GG$, show that BLS is *secure*: Note that in $GG$, DDH is false, since DDH is just to differentiate,
where CDH requires computation, and we may differentiate quite easily, since this group is bilinear. \
Let us consider the game: 
$
  A & <- vk = g ^ (a) \
  A & -> m \
    & <- H(m) ^ (a) \
    & -> m^*, sigma^*
$
Let us state that $H$ is some public function, which receives queries from either side, and deterministically returns
the results.
We may assume w.l.o.g:
+ $A$ queries $H$ on $m^*$. This is true, since $A$ need not use the result of $H$
+ $A$ never queries $H$ twice with the same $m$. This is true since $H$ is deterministic, so there would be no point in
  calling it twice on the same input, we may simply store the previous input, or add a wrapper, or something.

So, if CDH holds then BLS is secure: We shall create a reduction to a CDH adversary $B$, which accepts $g ^ (a), g ^
(b)$, and returns $g ^ (a b)$. \
$A$ may request 2 things, request a signature, and request a hash. $A$ expects to receive a verification key. 
+ $B$ sends $A$ $(g, g ^ (a))$, so $g ^ (a)$ is the $vk$ 
+ $forall H$ query on $m_i$, $g ^ (r_i) : r_i <- ZZ_p$
+ Guess index $i^*$ on which $A$ will request $H(m^*)$, and on the query $i^*$ to $H$, return $g ^ (b)$
+ $forall $ sign query on $m_i$, return $(g ^ (a)) ^ (r_i)$
+ If we were right, then we get $m^*, sigma^*$, and we may return the signature. Otherwise, fail
We still need to show that the distributions of the signatures, and of what $B$ returns are statistically equivalent,
but this is quite easily done. We have also assumed the programmable random model, where $B$ controls $H$, which is not
necessarily trivial, but the alternative is _much_ more complex.

= Identity Based Encryption
In traditional public key encryption, every person has a secret key, and a public key, someone maintains the public key
database, and through this, we may all communicate. The idea here is to simplify this such that we encrypt with respect
to someone's identity, as in their email address, or name, or some such. 

So, we have some certificate authority, which distributes the secret key according to your email. This idea was first
introduced by Shamir in 1984. In around 2001, Boneh Franklin (as in BLS) proposed the most popular form of identity
based encryption.

#let msk = $m s k$
#let mpk = $m p k$
#let psk = $p s k$
#let id = $i d$
#let ct = $c t$
$
  "Setup"(1) = msk, mpk \
  "KeyGen"(msk, id) =  sk_id \
  "Enc"(mpk, id, m) = c t_(id, m) \
  "Dec"(sk_id, id, c t_(id, m))
$
Yes, this does mean that our CA knows your secret key. We are working under the assumption that we are all working
together in a company, that is our CA, and we have no secrets from them, so by allowing this, we have saved $O(n ^ (2))$
space.

*Correctness*: 
$
  forall msk, mpk <- "Setup" \
  forall id, forall sk_id <- "KeyGen"(msk, id) \
  forall m, "Enc"(mpk, id, m) -> c t \
  "Dec"(sk_id, id, c t) = m
$

*Security*: The game is as follows.
+ We send the adversary $mpk$, having sampled $mpk, msk$
+ Adversary requests the secret key for some $id$
+ The adversary sends $id^*, m_0, m_1$, where $id^*$ is the $id$ it is trying to break, and someone for whom it has not
  received the $sk$
+ We sample $b <- {0, 1}$, and send $"Enc"(m_b)$
+ $A$ returns $b'$, and wins if $b' == b$
We may further strengthen this by having another round of id requesting, and even CCA style with multiple encryption
requests, and so on.

== Boneh Franklin IBE Scheme
+ Setup: $s <- ZZ_p$, and let $msk = s, mpk = g ^ (s) = h$
+ KeyGen$(msk, id)$: $sk_id = H(id) ^ (s)$
+ Enc$(mpk, id, m)$: $r <- ZZ_p, u = g ^ (r), v = e(H(id), h ^ (r)) dot m$, output $c = (u, v)$
+ Dec$(sk_id, id, ct = (u, v))$: $z = e(sk_id, u)$ output $m = v / z$

*Correctness*: $
  e(sk_id, u) = e(H(id) ^ (s), g ^ (r)) = e (g ^ (alpha s), g ^ (r)) = e (g, g) ^ (alpha s r) = e (H(id), h ^ (r))
$
So when we divide, we are left with $m$.

*Security*: We will use a reduction to the game in order to break DBDH, where we distinguish between $e(g, g) ^ (a b c)$
and $e(g, g) ^ (r)$, given $g ^ (a), g ^ (b), g ^ (c)$. So, we will construct $B(h_1 = g ^ (x), h_2 = g ^ (y), h_3 = g ^
(z), h_T)$ \
We will begin with the same assumptions, that $A$ never queries $H$ twice on the same input, and that $A$ always queries
$H(id)$ before sending it.
+ Send $A$ the $mpk = h_1$. Sample $j <- {1, dots, q}$ as the index of $id^*$ from all the $q$ queries that $A$ will do
+ $H$ query ($i$-th such query)
  - $i = j ==> H(id_i) = h_2$
  - $i != j ==> H(id_i) = g ^ (r_i) : r_i$ is randomly sampled
+ KeyGen$(id)$: $h_1 ^ (r_i)$
+ $h_3, h_T dot m_b$
If $h_T$ is random, then there no chance. However, if $h_T = e(g, g) ^ (x y z)$, and we have correctly chosen $j$, then
it has some minor advantage. The pk seen by $A$ is random, and all the random oracle queries appear completely random.
So, everything seen by the adversary appears completely random, as it should. We just need to show that the encryption
appears correct, which is to say, $(u, v)$ has the correct distribution. $u = g ^ (z)$, so does, and 
$
v & = e(h_2, h_1 ^(z)) \
  & = e(g ^ (y, g ^ (x z))) \
  & = e(g, g) ^ (x, y, z)
$
as required.

