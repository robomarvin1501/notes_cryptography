#set document(
  title: [Lecture 7 - Lattice Based Cryptography],
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
  2026-06-17
]

#let colourmaths(x, color) = text(fill: color)[$#x$]
#let LWE = $L W E$
#let KeyGen = "KeyGen"
#let Enc = "Enc"
#let Dec = "Dec"
#let pk = $p k$
#let sk = $s k$
#let ct = $c t$

#figure()[Notice: If you find any mistakes, please open an issue in #link("https://github.com/robomarvin1501/notes_crypto")[the github repository]]

= Introduction
== ...Why?
Lattices are a new mathematical basis for cryptography. It's easy to ask why we need this, we already have RSA, DLOG,
DDH and so on, and last lecture we also learnt about bilinear groups. One reason is that non of the previously learnt
methods are not secure when we have quantum computers. For example, Shor showed in 1996 that quantum computers can
(relatively easily) break RSA, DLOG, and so on. Currently, lattices are plausibly resistant to quantum computers (just
as DDH is plausibly resistant against traditional computers). It is also interesting, and brings us new capabilities,
much like how bilinear groups brought new capabilities impossible just over RSA/DLOG.

== What
Let us suppose that we have the following 3 inequalities:
$
    3 x_1 + 4 x_2 + x_3 & = 0 \
  4 x_1 + 2 x_2 + 6 x_3 & = 1 \
        x_1 + x_2 + x_3 & = 1 \
$
All over $mod 7$. If we want to find $x_1, x_2, x_3$, it is quite trivial, and we find them to be $1, -1, 1$. This is
called Gaussian elimination (as taught in linear algebra 1). We can also construct this with simplifying matrices and
vectors, $A x = b$. \
This initial idea is trivial, but if we add in some noise $e$, such that we are now trying to find $x$ where $A x + e =
b$, then Gaussian elimination no longer works.

Let us now consider that we have $A x in ZZ_q$, and some "little noise" $e$. If $e$ is completely random, then it
completely hides what $x$ might be, and we do not have enough information to be able to establish the value of $x$.
However, if we say that $e$ is little, limited in some sort of range, then perhaps we can do more.

We can also consider when $A, x in FF_2$, so they are binary. Then, we may define $e$ where each part has a value of 1
with probability $p$. So, for each inner product $lr(chevron.l a_i, x_i chevron.r) + e$, where for each value, we flip
it with probability $p$. This is also impossible in Gaussian elimination.

We are going to focus on the $ZZ_q$ option.

#pagebreak()
= Lattices
We are used to $ZZ_q = {0, dots, q - 1}$. However, to make our life simpler here, we will instead define
$
  ZZ_q = {-q/2,dots, q / 2}
$
Additionally, we will define
$
                 e & = (e_1, dots, d_n) in ZZ_q \
  norm(e)_infinity & = max e_i
$
We will also define B-bounded, which means
$
  Pr [norm(e)_infinity <= B] = 1
$

We will assume:
$
  LWE(n, m, q, X_B)
$
Where $X_B$ is a B bounded distribution. We will also sample $A <- ZZ^(m times n)_q, s <- ZZ^n_q, e <- X_B$. We will
define search $LWE$, where given $A, A s + e)$, find $s'$ such that
$
  norm(A s' - (A s - e))_infinity <= B
$

The essential idea is given a set of inequalities, with some B bounded noise, to find a value $s' = s$, within the limit
of the B bounding.

We are considering all possible $s$ in some field $ZZ^n_q$, and a mapping $A$ to another field $ZZ^m_q$. This little
noise means instead of mapping to a single other value, it maps to some small _group_ of values in the field $ZZ^m_q$.
Given a point in one of these circles in $ZZ^m_q$ (which may be overlapped with other circles, and all other problems),
we want to find the original $s$ that leads to it.

_Theorem_: For every PPT algorithm $cal(A)$,
$
  Pr[cal(A)(A, A s + e) = s'] <= "negl"(n)
$
We generally prefer to define with indistinguishability, so instead:
_Theorem_: LWE for all PPT adversary, it cannot distinguish between
$
  (A, A s + e) approx (A, u) : u in ZZ^m_q
$
This theorem is not particularly young, but converting it to make public key cryptography was a relatively recent
development, from a professor in Tel Aviv university.

There is a theorem that LWE is equivalent to search LWE. We will probably have to prove it in our homework.

= Regev's LWE PK Encryption Scheme
Let
$
  KeyGen(1^(n)) & -> A <- ZZ^(m times n)_q \
                & s <- ZZ^n_q \
                & c <- X^m_B \
                & b = A s + e \
                & sk = s \
                & pk = (A, b) in ZZ^(m times (n + 1))_q \
$
So, $Enc(pk, x in {0, 1})$:
$
    r & <- {0, 1}^(m) \
  c_0 & = r^T A \
  c_1 & = r^T dot b + floor(q / 2) dot x \
  c t & = (c_0, c_1) in ZZ^n_q times ZZ_q
$
So this $r$ means we are taking a random subset of rows from $A$, a random subset of answers from $b$, and adding on to
the second either 0, or a very large number. \
Our objective in decoding is to approximately remove the $r^T b$ value, since if $x=0$, then we get some small value,
and if $x=1$ we will get a very large value.

So, $Dec(sk, (c_0, c_1))$:
$
  tilde(x) & = c_1 - c_0 dot s \
  "output" & = cases(
               0 "if" tilde(x) < q / 4,
               1 "else"
             )
$

*Correctness*:
$
  c_1 = c_0 dot s & = r^T dot b + floor(q / 2) dot x - r^T A dot s \
                  & = r^T (A s + e) + floor(q / 2) x - r^T A s \
                  & = r^T A s + r^T e + floor(q / 2) x - r^T A s \
                  & = r^T e + floor(q / 2) x \
$
and $r^T dot e$ is limited by the size of $m B < q / 4$, so correctness holds with very high probability.

*Security*: We want to prove equivalence between $pk = (A, b = A s + e)$, and $pk = (A, b = u)$, for a random uniform
$u$. This is tricky, and we will need to use the Leftover Hash Lemma: \
_Lemma_: Leftover Hash Lemma: Let
$
  m & >= 2 n log q \
  H \
  A & <- ZZ^(m times n)_q \
  x & <- {0, 1}^(m) \
  y & <- ZZ^n_q \
$
So,
$
  (A, x^T A) approx_("statistically") (A, y)
$
So, we take a very large matrix, and sum together sum subset of its rows. We are asking if some random vector is in fact
random, or came from the sum of random subset of rows.

If we now construct the three hybrids:
$
  pk & = (A, b = A s + e), c_0 = r^T A, c_1 = r^T b + floor(q / 2) dot x \
  pk & = (A, b = u), c_0 = r^T A, c_1 = r^T u + floor(q / 2) dot x \
  pk & = (A, b = u), c_0 = u', c_1 = r^T u + floor(q / 2) dot x \
$
And we may see that it is statistically indistinguishable from the Leftover Hash Lemma.

#pagebreak()
= Lattice Mathematics
We said earlier that LWE problems are "lattice problems", but what even is a lattice? We will discuss this in relatively
high level terms, and we may read more if we so desire.

A lattice is a set of points in $ZZ_n$, that are linear combinations of basis vectors $B = {arrow(b)_1, dots, arrow(b)_n}$. So we have
$n$ basis vectors, which we recombine into a lattice:
$
  L = {sum_(i=1)^(n)a_i arrow(b)_i : a_i in ZZ}
$

We can now do all sorts of problems over this lattice, such as the Closest Vector Problem (CVP), where given a point $t
in ZZ^n$, and we are asked to bring a vector in the lattice $v in L(B)$, such that $norm(v - t)$ is minimal. There is
also SVP, shortest vector problem, where we find the "shortest" vector $u in L(B)$. \
So we have problems like this, which appear to be hard, and we assume them to be hard in the worst case, much like how
for satisfiability, where we assume that there is no algorithm for everything, only specific solutions. Here we assume
that there is no algorithm for any basis, just specific bases.

We can also convert these to approximate algorithms (approximation of $gamma$), where instead of finding the minimum, we
find one of the solutions that is approximately minimal. For large $gamma$ this is possible, but for small constant
$gamma$, it remains NP-hard. What is interesting, is if we believe that the problem is also hard for $gamma = "poly"(n)$
in the worst case, then so too is LWE (which is average case, not worst case). This is wonderful, because it means we
can make the assumption for Regev under a worst case assumption, rather than average case.

= FHE (Fully Homomorphic Encryption)
(Allow us to compute over encrypted data, without decrypting it)

Created in 2009 by Gentry in Stanford, first time anyone created any system capable of this. In 2011, B&V showed that
Gentry's system may be done with LWE. In 2013, G(entry from earlier)SW created a new method with LWE, which is much
simpler than that of BV.

#let Eval = "Eval"
Let us begin with what we have:
$
              KeyGen(1^(n)) & -> sk, pk \
                 Enc(pk, m) & -> ct \
                Dec(sk, ct) & -> m \
  Eval(f, ct_1, dots, ct-d) & -> ct' \
$
*Correctness*: $Dec(sk, Eval(f, ct_1, dots, ct_l)) = f(m_1, dots, m_l)$

*Security*: We will want to show that $forall m_0, m_1, Enc(pk, m_0) approx Enc(pk, m_1)$. From these two, we could
simply have eval return its input, and decryption will decrypt, and then apply $f$. To avoid this, we will also define
conciseness:

*Conciseness*: $abs(ct' <= "poly"(n))$

So, how do we construct this properly?
- Phase 1: $f$ is bounded depth, and $exists p(dot)$ such that the depth of $f$ is $<= "poly"(n)$. This is leveled
  homomorphic encryption
- Phase 2: move from leveled, to fully arbitrary $f$

== Idea
We will build a scheme where the secret key is a vector $arrow(s)$, and encryptions are matrices $C$ such that $C s = mu
s$, where $mu$ is a constant, so $s$ is an eigenvector of $C$, with respect to the eigenvalue $mu$. \
Decryption is simply finding the value of $mu$, since it is our message here.

This is useful, since if for message $mu_1$, we have the ciphertext $C_1$, and for $mu_2$ we have $C_2$, then we may
compute the sum of the messages without decryption since
$
  (C_1 + C_2) s = (mu_1 + mu_2) s
$
What about multiplication?
$
  (C_1 dot C_2) s & = C_1 dot mu_2 s \
                  & = mu_1 dot mu_2 s \
$

=== Attempt 1 (Secret Key)
The definition of $s$ below is just to make the writing easier.
$
  KeyGen: arrow(s) & = ZZ^(n - 1)_q \
          arrow(s) & = vec(tilde(s), -1) in ZZ^n_q \
    Enc(s, mu) : A & <- ZZ^(n times (n - 1))_q \
                 e & <- X^n_B \
                 c & = (A, A arrow(tilde(s)) + arrow(e)) + mu I_n in ZZ^(n times n)_q \
  Dec(arrow(s), c) & = "Compute" C dot arrow(s) \
                   & "output" cases(0 "if" norm(C dot s) "is small", 1 "else")
$

Let us consider encryption:
$
  C dot arrow(s) & = (A, A arrow(tilde(s)) + e) vec(arrow(tilde(s)), -1) + mu I_n dot arrow(s) \
                 & = A arrow(tilde(s)) - (A arrow(tilde(s)) + e) + mu arrow(s) \
                 & = mu arrow(s) - e
$
Let us now check this for evaluation:
$
  (c_1 + c_2) s & = (mu_1 s + e_1) + (mu_2 s + e_2) \
                & = (mu_1 + mu_2) s + (e_1 + e_1) \
  (c_1 dot c_2) & = c_1(mu_2 s + e_2) \
                & = mu_2 (mu_1 s + e_1) + c_1 dot e_2 \
                & = (mu_1 dot mu_2 s) + (mu_2 dot e_1 + c_1 dot e_2)
$
Which is not good, since $c_2$ is a large value, times a small value, so it is not ignorable noise. We want to ensure
that $c_1$ is small, and we will do that next week.

=== Attempt 2
We will create a variation such that the matrices are not only matrices with eigenvector $s$, but the values inside
these matrices are incredibly small. \
We may reduce the size of the used number by encoding all the numbers in binary. This way, all our numbers are small (0
or 1):
$
  hat(x) & = (x_0, dots, x_(log(q - 1)))
$
So, we may (with a linear function) compute $x = sum_i x_i 2^i$. This may be extended to vectors by encoding each number
in a flat vector, since we know how many values correspond to each $x$. To convert this vector, we may multiply by the
matrix $G$, since converting each value of the vector is a linear operation. This $G$ will have a column corresponding
to each value in the vector, and at the correct height of this column will be the values $1, 2, 4, dots, log(q - 1)$. \
It is easy to convince ourselves from here that there exists an inverse matrix $G^(-1)$. \
We may similarly extend this from an input vector, to an input matrix.

#pagebreak()
Let us define:
$
       KeyGen: s & = vec(tilde(s), -1) in ZZ^n_q \
  Enc(s, mu) : A & <- ZZ^(m times (n - 1)) : m = n log q \
               e & ~ X^n_B \
               c & = [(A | A tilde(s) + e) + mu I_n] dot G : G in FF_(n times n log q) \
       Dec(s, c) & = C dot G^(-1) dot s \
                 & = ((A | A s + e) + mu I) dot s
$

*Correctness*:
$
  C dot s & = (A | A tilde(s) + e) vec(tilde(s), -1) + mu G s \
          & = e + mu G s
$
Additional homomorphism:
$
  (C_1 + C_2) dot s & = (A | A tilde(s) + e_1) s + (A | A tilde(s) + e_2) s + mu_1 G s + mu_2 G s \
                    & = ((A | A tilde(s) + e) + (mu_1 + mu_2) G) s
$
Multiplication homomorphism:
$
  C_1 dot C_2 s & = C_1 dot (e + mu_2 G s) \
                & = C_1 e + mu_2 C_1 G s
$
This did not really help, since we are still multiplying the big $C_1$ by the error, and we are multiplying $C_1$ by
$G$. Let us define $h(C) G = C$, so $h$ is a function that does the inverse operation of $G$, and converts a matrix to
binary.
$
  h(C_1) dot C_2 s & = h(C_1) dot (e + mu_2 G s) \
                   & = h(C_1) e + mu_2 h(C_1) G s
$
Since $h(C_1)$ is only zeroes and ones, $h(C_1) e$ remains small. Therefore:
$
  h(C_1) dot C_2 s & = h(C_1) dot (e + mu_2 G s) \
                   & = h(C_1) e + mu_2 h(C_1) G s \
                   & = h(C_1) e + mu_2 C_1 s \
                   & = h(C_1) e + mu_2 (e + mu_1 G s) \
                   & = h(C_1) e + mu_1 mu_2 G s + mu_2 e
$
The problem here is that the size of $epsilon$ increases with the number of homomorphic encryptions. If we perform
$
  Enc(1) times dots times Enc(1)
$
Then after the first encryption we have noise of $epsilon$, the second we have the same result, but noise
$O(epsilon^2)$, and so on until we wind up with $O(epsilon^t)$, which is really quite large, and we have ruined the
homomorphism.

What we may do now, is take an encrypted form of the secret key, and use it to homomorphically decrypt the message. As a
result, we have created a new encryption with error $epsilon$ of the final value, and from there we may continue. \
This comes with the caveat that it is not exactly accurate that the encryption of the secret key does not bring us any
information as an adversary. It is seemingly impossible to prove that security schemes are secure against knowledge of
an encrypted form of the secret key, so we make this an assumption. This assumption is called _circular security_.
