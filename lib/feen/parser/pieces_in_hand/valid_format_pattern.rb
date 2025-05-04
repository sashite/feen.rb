# frozen_string_literal: true

module Feen
  module Parser
    module PiecesInHand
      # Valid pattern for pieces in hand based on BNF:
      # <pieces-in-hand> ::= "-" | <A-part> <B-part> ... <Z-part> <a-part> <b-part> ... <z-part>
      # where each part can be empty or contain repetitions of the same letter
      ValidFormatPattern = /\A(?:-|
        A*B*C*D*E*F*G*H*I*J*K*L*M*N*O*P*Q*R*S*T*U*V*W*X*Y*Z*
        a*b*c*d*e*f*g*h*i*j*k*l*m*n*o*p*q*r*s*t*u*v*w*x*y*z*
      )\z/x
    end
  end
end
